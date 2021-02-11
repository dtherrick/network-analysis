
%let _COMMON_REPO_ROOT=&_SASPROGRAMFILE/../../../../../common;
%INCLUDE "&_SASPROGRAMFILE/../../../../../common/sas/cas_connection.sas";
%INCLUDE "&_SASPROGRAMFILE/../../../../../common/sas/visualization.sas";


/******************/
/* CAS Connection */
/******************/

%reconnect();

/****************************/
/* Generate Word Embeddings */
/****************************/

/** Assign weights to word pairs (1 = perfect synonym, 0 = unrelated word) **/
/** In practice, pre-trained word embeddings could be used instead of learning them here. **/
/** These would typically be trained based on co-occurence frequency in a large corpus. **/
data mycas.synonymLinks;
   input from $ to $ weight;
   datalines;
music dvd 0.1
music mp3 0.9
music video 0.3
book mp3 0.1
dvd video 0.95
mp3 video 0.1
;

/** Train word embeddings using vector node similarity, first order proximity **/
%let nDim=10;
%let convergenceThreshold=0.00001;
%let nSamples=1000000;
proc network
   links           = mycas.synonymLinks
   outNodes        = mycas.wordEmbeddings
   ;
   linksVar
   weight          = weight
   ;
   nodesimilarity
   vector          = true
   jaccard         = false
   proximityorder  = first 
   nDimensions     = &nDim
   convergenceThreshold = &convergenceThreshold
   nSamples        = &nSamples
   outSimilarity   = mycas.outSim
   ;
run;

/** Show the word similarity computed based on trained embeddings **/
proc print data=mycas.outSim; by source; run;

options printerpath=svg nodate nonumber papersize=('2.75in','2.1in');
ods printer file="&_SASPROGRAMFILE/../../svg/word_embeddings_0.svg" NEWFILE=PAGE;
proc print data=mycas.synonymLinks; run;
ods printer close;


options printerpath=svg nodate nonumber papersize=('2.75in','7.75in');
ods printer file="&_SASPROGRAMFILE/../../svg/word_embeddings_1.svg" NEWFILE=PAGE;
proc print data=mycas.outSim; by source; run;
ods printer close;    


/*********************************************************/
/* Approximate Pattern Matching Based on Word Embeddings */
/*********************************************************/

/** Main graph: purchase history for 6 people for 5 categories of products **/
data mycas.NodesPurchase;
   length node $8 type $8 color $8 longName $40 label $52;
   input node $ type $ longName $;
   if      type EQ 'music' then color='1';
   else if type EQ 'mp3'   then color='2';
   else if type EQ 'video' then color='3';
   else if type EQ 'dvd'   then color='4';
   else if type EQ 'book'  then color='5';
   else                         color='white';
   label = CATS(longName,'\n','(',type,')');
   datalines;
1      person Amy
2      person Blaine
3      person Catherine
4      person Dexter
5      person Edwin
6      person Faye
MUSIC1 music  Dark_Side_of_the_Moon
MUSIC2 music  Led_Zeppelin
MP3A   mp3    Back_in_Black
MP3B   mp3    From_This_Moment_On
VIDEO1 video  Star_Wars
DVD1   dvd    The_West_Wing
DVD2   dvd    King_Kong
BOOK1  book   Catcher_in_the_Rye
BOOK2  book   Little_Women
BOOK3  book   The_Bell_Jar
;

data mycas.LinksPurchase;
   length from $8. to $8.;
   input from $ to $;
   datalines;
1 MUSIC1
1 MP3A
1 VIDEO1
2 MUSIC1
2 MP3A
3 VIDEO1
3 MUSIC1
3 DVD1
3 DVD2
3 BOOK1
4 MP3A
4 BOOK1
4 BOOK2
4 BOOK3
5 MP3B
5 MUSIC2
5 DVD1
5 DVD2
5 VIDEO1
6 DVD2
6 VIDEO1
6 BOOK3
6 MP3A
;

/** Query graph: find pair of persons who purchased the same 2 video items **/
data mycas.nodesQuery;
   length node $8. type $8.;
   input node $ type $;
   datalines;
Person1 person
Person2 person
Video1  video
Video2  video
;
data mycas.LinksQuery;
   length from $8. to $8.;
   input from $ to $;
   datalines;
Person1 Video1
Person1 Video2
Person2 Video1
Person2 Video2
;

/** Merge nodes with word embeddings **/
data mycas.NodesQueryEmbed;
   merge mycas.NodesQuery(in = nodeIn) mycas.wordEmbeddings(rename=(node=type));
   by type;
   if nodeIn;
run;
data mycas.NodesPurchaseEmbed;
   merge mycas.NodesPurchase(in = nodeIn) mycas.wordEmbeddings(rename=(node=type));
   by type;
   if nodeIn;
run;


/** Macro Definitions **/

/* Generate expressions for fcmp variable lists */
/*
varsCommaN      = n.vec_1,nQ.vec_1,n.vec_2,nQ.vec_2,...
varsDotProductN = n.vec_1*nQ.vec_1+n.vec_2*nQ.vec_2+...
*/
data _null_;
   length varsCommaN varsDotProductN VARCHAR(32767);
   varsCommaN      = '';
   varsDotProductN = '';
   do i = 1 to &nDim;
     varsCommaN     = catx(',',varsCommaN,     cats('n.vec_', i,',nQ.vec_',i));
     varsDotProductN= catx('+',varsDotProductN,cats('n.vec_', i,'*nQ.vec_',i));
   end;
   call symput('varsCommaN',      trim(varsCommaN));
   call symput('varsDotProductN', trim(varsDotProductN));
run;

/* GetValue() is used to grab the value of a field in _NETWORK_ result macro variable */
%macro GetValue(mac=, item=);
   %let prs = %sysfunc(prxparse(m/\b&item=/i));
   %if %sysfunc(prxmatch(&prs, &&&mac)) %then %do;
      %let prs = %sysfunc(prxparse(s/.*\b&item=([^ ]+).*/$1/i));
      %let return_val = %sysfunc(prxchange(&prs, 1, &&&mac));
      &return_val
   %end;
   %else %do;
      %put ERROR: Cannot find &item!;
        .
   %end;
%mend;

/* Consider two types to be equivalent if the vector dot product value exceeds this threshold */
%let fuzzyMatchThreshold=0.7;

/** FCMP Definitions **/
proc cas;
   source myFilters;
      /** Node filter: we require exact match for type=person, approximate match otherwise **/
      function nodeFilter(n.type $, nQ.type $, &varsCommaN);
         if (nQ.type EQ 'person') then return (n.type EQ nQ.type);
         if (&varsDotProductN > &fuzzyMatchThreshold) then return (1);
         return (0);
      endsub;

      /** Node pair filter: don't enumerate redundant (symmetric) permutations **/
      function nodePairFilter(n.node[*] $, nQ.node[*] $);
         if(nQ.node[1] EQ 'Person1' AND nQ.node[2] EQ 'Person2') then return (n.node[1] LT n.node[2]);
         if(nQ.node[1] EQ 'Video1' AND nQ.node[2] EQ 'Video2') then return (n.node[1] LT n.node[2]);
         return (1);
      endsub;
   endsource;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.myRoutines"}; run;
   fcmpact.addRoutines /
   saveTable = true,
   funcTable = {name="myRoutines", caslib="casuser", replace=true},
   package = "myPackage",
   routineCode = myFilters;
   run;
quit;

/* Approximate PatternMatch */
proc network
   direction          = directed
   links              = mycas.LinksPurchase
   linksQuery         = mycas.LinksQuery
   nodes              = mycas.NodesPurchaseEmbed
   nodesQuery         = mycas.NodesQueryEmbed
   ;
   nodesVar      vars = (type longName vec_1-vec_&nDim);
   nodesQueryVar vars = (type vec_1-vec_&nDim) varsMatch=();
   patternMatch
      outMatchNodes   = mycas.OutMatchNodes
      outMatchLinks   = mycas.OutMatchLinks
      nodeFilter      = nodeFilter(n.type, nQ.type, &varsCommaN.)
      nodePairFilter  = nodePairFilter(n.node, nQ.node)
   ;
run;

%let numMatches = %GetValue(mac=_network_,item=num_matches);

/*****************************/
/* Input Graph Visualization */
/*****************************/

proc sort out=nodesPurchase data=mycas.NodesPurchase;
   by descending node;
run;

proc sort out=linksPurchase data=mycas.LinksPurchase;
   by from to;
run;

data _NULL_;
   file "&_SASPROGRAMFILE/../../dot/approximate_patternmatch_0.dot";
%graph2dot(
   nodes=nodesPurchase,
   links=linksPurchase,
   nodesAttrs="colorscheme=paired8, style=filled, color=black",
   nodeAttrs="fillcolor=color, label=label",
   graphAttrs="layout=sfdp, overlap=prism, overlap_scaling=-3",
   directed=1
);
run;

/*****************************/
/* Query Graph Visualization */
/*****************************/

data _NULL_;
   file "&_SASPROGRAMFILE/../../dot/approximate_patternmatch_1.dot";
%graph2dot(
   links=mycas.LinksQuery,
   graphAttrs="layout=sfdp",
   directed=1
);
run;

/*******************************/
/* Matches Found Visualization */
/*******************************/

%macro visualizeMatches();
%let highlightColor='blue';
%let highlightThickness=3;

%do selectedMatch=1 %to &numMatches;
data mycas.LinksPurchaseHighlighted;
   merge mycas.LinksPurchase
         mycas.outMatchLinks(in=inMatch where=(match=&selectedMatch));
   by from to;
   if inMatch then do;
      color=&highlightColor;
      thickness=&highlightThickness;
   end;
run;
data mycas.NodesPurchaseHighlighted;
   merge mycas.NodesPurchase
         mycas.outMatchNodes(in=inMatch where=(match=&selectedMatch));
   by node;
   if inMatch then do;
      pencolor=&highlightColor;
      thickness=&highlightThickness;
   end;
run;
proc sort out=nodesPurchaseHighlighted data=mycas.NodesPurchaseHighlighted;
   by descending node;
run;

proc sort out=linksPurchaseHighlighted data=mycas.LinksPurchaseHighlighted;
   by from to;
run;

 %let FILE_N = %EVAL(1 + &selectedMatch);
data _NULL_;
   file "&_SASPROGRAMFILE/../../dot/approximate_patternmatch_&FILE_N..dot";
%graph2dot(
   nodes=nodesPurchaseHighlighted,
   links=linksPurchaseHighlighted,
   nodesAttrs="colorscheme=paired8, style=filled, color=black",
   nodeAttrs="fillcolor=color, label=label, color=pencolor, penwidth=thickness",
   linkAttrs="color=color, penwidth=thickness",
   graphAttrs="layout=sfdp, overlap=prism, overlap_scaling=-3",
   directed=1
);
run;
%end;
%mend;

%visualizeMatches();
