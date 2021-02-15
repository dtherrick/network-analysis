/* Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0 */

%let _COMMON_REPO_ROOT=&_SASPROGRAMFILE/../../../../common;
%INCLUDE "&_COMMON_REPO_ROOT/sas/cas_connection.sas";
%INCLUDE "&_COMMON_REPO_ROOT/sas/visualization.sas";


/******************/
/* CAS Connection */
/******************/

%reconnect();


/*************/
/* Load Data */
/*************/
%macro LoadData(dataset);
  table.loadTable result = r / 
      casout={name="&dataset", replace=true}
      path="&dataset..sas7bdat"
      ;
  run;
%mend;

proc cas noqueue;
   %LoadData(inmates);
   %LoadData(cells);
   %LoadData(sections);
   %LoadData(prisons);
   %LoadData(regions);
   %LoadData(inmateSentences);
   %LoadData(inmateCell);
   %LoadData(cellSection);
   %LoadData(sectionPrison);
   %LoadData(prisonRegion);
quit;

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

%macro visualizeMatches(fileRoot, queryKey=_NULL_, num=&numMatches, layout=dot);
%let highlightColor='blue';
%let highlightThickness=3;

%do selectedMatch=1 %to &num;
data mycas.LinksInMatch;
%if %QUOTE(&queryKey) = _NULL_ %then %do;
   set mycas.outMatchLinks(where=(match=&selectedMatch));
%end;
%else %do;
   set mycas.outMatchLinks(where=(queryKey=&queryKey and match=&selectedMatch));
%end;
   length label $40;
   by from to;
   if start EQ . then label = "";
   else do;
      label = CATS(
         "[",
         put(start,DATETIME9.),
         ",",
         put(end,DATETIME9.),
         "]"
      );
   end;
run;
data mycas.NodesInMatch;
%if %QUOTE(&queryKey) = _NULL_ %then %do;
   set mycas.outMatchNodes(where=(match=&selectedMatch));
%end;
%else %do;
   set mycas.outMatchNodes(where=(queryKey=&queryKey and match=&selectedMatch));
%end;
   length label $40;
   by node;
   nodeLen = length(node);
   if      type EQ 'INMATE'  then color='1';
   else if type EQ 'CELL'    then color='2';
   else if type EQ 'SECTION' then color='3';
   if      type EQ 'INMATE'  then label=CATX('\n',firstName,lastName);
   else                           label=substr(node,nodeLen-5);
run;
proc sort out=nodesInMatch data=mycas.NodesInMatch;
   by descending nodeQ;
run;

proc sort out=linksInMatch data=mycas.LinksInMatch;
   by from to;
run;

 %let FILE_N = %EVAL(&selectedMatch);
data _NULL_;
   file "&_SASPROGRAMFILE/../dot/&fileRoot._&FILE_N..dot";
%graph2dot(
   nodes=nodesInMatch,
   links=linksInMatch,
   nodesAttrs="colorscheme=paired8, style=filled, color=black",
   nodeAttrs="fillcolor=color, label=label",
   linkAttrs="label=label",
   graphAttrs="layout=&layout",
   directed=1
);
run;
%end;
%mend;

/*************************/
/* Define and Load Graph */
/*************************/

/* Define the Nodes Table */
data mycas.nodes;
   length node $12 type $12;
   format node $12.;
   set mycas.inmates(rename=(inmateId=node)) indsname=dsn
       mycas.cells(rename=(cellId=node)) indsname=dsn
       mycas.sections(rename=(sectionId=node)) indsname=dsn
       mycas.prisons(rename=(prisonId=node)) indsname=dsn
       mycas.regions(rename=(regionId=node)) indsname=dsn;
   type = scan(dsn, 2, ".");
   type = substr(type, 1, length(type)-1);
   keep node type firstName lastName numSentences;
run;

/* Define the Links Table */
data mycas.links;
   length from $12 to $12;
   format from $12. to $12.;
   set mycas.inmateCell(rename=(inmateId=from cellId=to))
       mycas.cellSection(rename=(cellId=from sectionId=to))
       mycas.sectionPrison(rename=(sectionId=from prisonId=to))
       mycas.prisonRegion(rename=(prisonId=from regionId=to))
   ;
   keep from to sentenceId start end;
run;

%macro loadGraph();
   %if (%symexist(graphId)) %then %do;
      proc cas;
         network.unloadGraph result=r /
            display={excludeAll=TRUE} graph = &graphId;
      run;
      %symdel graphId;
   %end;
   proc cas;
      network.loadGraph result=r /
         display={excludeAll=TRUE}
         direction = "directed"
         links = {name="links"} 
         linksVar = {vars={"start", "end"}}
         nodes = {name="nodes"}
         nodesVar = {vars={"type", "firstName", "lastName"}};
      run;
      symput('graphId',(string)r.graph);
      print r;
   quit;
%mend loadGraph;

%loadGraph();

/************************/
/* PatternMatch Queries */
/************************/

/** Example 1**/
/* Find inmates that shared a cell with fictional mob boss Jett Mccormick */
data mycas.nodesQ;
   infile datalines dsd;
   length node $12 type $12 firstName $12 lastName $12;
   input node $ type $ firstName $ lastName $;
   datalines;
mobBoss, INMATE, Jett, Mccormick
inmate2, INMATE, , 
cell, CELL, , 
;
data mycas.linksQ;
   infile datalines dsd;
   length from $12 to $12;
   input from $ to $;
   datalines;
mobBoss, cell
inmate2, cell
;

/* Define FCMP Functions */
proc cas;
   source myFilter;
      function hasOverlap(start[*], end[*]);
         intervalTotal = MAX(end[1],end[2]) - MIN(start[1],start[2]);
         interval1 = end[1]-start[1];
         interval2 = end[2]-start[2];
         return (interval1 + interval2 GT intervalTotal);
      endsub;
      function myLinkPairFilter1(start[*], end[*]);
         return (hasOverlap(start, end));
      endsub;
   endsource;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.myRoutines"}; run;
   fcmpact.addRoutines /
      saveTable   = true,
      funcTable   = {name="myRoutines", caslib="casuser", replace=true},
      package     = "myPackage",
      routineCode = myFilter;
   run;
quit;

proc network
   graph            = &graphId
   nodesQuery       = mycas.nodesQ
   linksQuery       = mycas.linksQ;
   nodesQueryVar
      vars          = (type firstName lastName);
   patternMatch
      LinkPairFilter = myLinkPairFilter1(l.start, l.end)
      outMatchNodes = mycas.OutMatchNodes
      outMatchLinks = mycas.OutMatchLinks
      maxMatches    = 100;
run;
%let numMatches = %GetValue(mac=_network_,item=num_matches);

%macro joinNodeInfo(outputTable, nodesTable, outputKey, nodesKey, outputVarName, nodesExpr);
   proc fedsql sessref=mySession;
      create table &outputTable {options replace=true} as
      select &NodesExpr as &outputVarName, a.*
      from &outputTable as a
      join &nodesTable as b
      on a.&outputKey = b.&nodesKey
      ;
   quit;
%mend joinNodeInfo;

%joinNodeInfo(outMatchLinks, inmates, from, inmateId, name, (firstName || ' ' || lastName));

title "Inmates Sharing a cell with Jett Mccormick";
proc print data=mycas.outMatchLinks noobs label;
   by match to;
   label from="inmateId" to="cellId";
run;
title;


/*******************************/
/* Matches Found Visualization */
/*******************************/


%visualizeMatches(query_1_match);



/** Example 2: **/
/* Find inmates in the same section as Jett Mccormick */
data mycas.nodesQ;
   infile datalines dsd;
   length querykey $2 node $12 type $12 firstName $12 lastName $12;
   input querykey $ node $ type $ firstName $ lastName $;
   datalines;
0, mobBoss, INMATE, Jett, Mccormick
0, inmate2, INMATE, , 
0, cell, CELL, , 
1, mobBoss, INMATE, Jett, Mccormick
1, inmate2, INMATE, , 
1, cell1, CELL, , 
1, cell2, CELL, ,
1, section, SECTION, ,
;
data mycas.linksQ;
   infile datalines dsd;
   length querykey $2 from $12 to $12;
   input querykey $ from $ to $;
   datalines;
0, mobBoss, cell
0, inmate2, cell
1, mobBoss, cell1
1, inmate2, cell2
1, cell1, section
1, cell2, section
;

/** Define FCMP Functions **/
proc cas;
   source myFilter;
      function myLinkPairFilter2(start[*], end[*]);
         if(start[1] NE . AND start[2] NE .) then
            return (hasOverlap(start, end));
         return (1);
      endsub;
   endsource;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.myRoutines"}; run;
   fcmpact.addRoutines /
      appendTable = true,
      saveTable   = true,
      funcTable   = {name="myRoutines", caslib="casuser", replace=true},
      package     = "myPackage",
      routineCode = myFilter;
   run;
quit;

proc network
   graph            = &graphId
   nodesQuery       = mycas.nodesQ
   linksQuery       = mycas.linksQ;
   nodesQueryVar
      vars          = (type firstName lastName);
   patternMatch
      LinkPairFilter= myLinkPairFilter2(l.start, l.end)
      outMatchNodes = mycas.OutMatchNodes
      outMatchLinks = mycas.OutMatchLinks
      queryKey      = querykey
      maxMatches    = 1000;
run;

proc sort data=mycas.outMatchNodes out=outMatchNodes; by queryKey match type nodeQ;
title "Inmates in same Section at same time as Jett Mccormick";
proc print 
   data=outMatchNodes(where=
      (type="INMATE" OR nodeQ="section" OR
      (nodeQ="cell" AND queryKey="0")
      )
      obs=50);
   by querykey;
run;
title;

%let numMatches = 5;
%visualizeMatches(query_2_match, queryKey="1");

/** Example 3: **/
/* Find "cliques" of cell-sharing inmates */
data mycas.nodesQ;
   infile datalines dsd;
   length querykey $2 node $12 type $12;
   input querykey $ node $ type $ ordering;
   datalines;
0, inmate1, INMATE,1
0, inmate2, INMATE,2
0, inmate3, INMATE,3
0, cellA, CELL,.
0, cellB, CELL,.
0, cellC, CELL,.
1, inmate1, INMATE,1
1, inmate2, INMATE,2
1, inmate3, INMATE,.
1, cellA, CELL,.
1, cellB, CELL,.
2, inmate1, INMATE,1
2, inmate2, INMATE,2
2, inmate3, INMATE,.
2, cellA, CELL,.
3, inmate1, INMATE,1
3, inmate2, INMATE,2
3, inmate3, INMATE,.
3, cellA, CELL,.
;
data mycas.linksQ;
   infile datalines dsd;
   length querykey $2 from $12 to $12;
   input querykey $ from $ to $ constrain;
   datalines;
0, inmate1, cellA,1
0, inmate2, cellA,1
0, inmate2, cellB,2
0, inmate3, cellB,2
0, inmate3, cellC,4
0, inmate1, cellC,4
1, inmate1, cellA,1
1, inmate2, cellA,2
1, inmate3, cellA,3
1, inmate1, cellB,4
1, inmate2, cellB,4
2, inmate1, cellA,1
2, inmate2, cellA,1
2, inmate2, cellA,2
2, inmate3, cellA,2
2, inmate3, cellA,3
3, inmate1, cellA,5
3, inmate2, cellA,6
3, inmate3, cellA,1
3, inmate3, cellA,2
;

/** Define FCMP Functions **/
proc cas;
   source myFilter;
      function myLinkPairFilter3(from[*] $, start[*], end[*], constrain[*]);
         if(BAND(constrain[1], constrain[2]) GT 0 AND from[1] LT from[2]) then
            return (hasOverlap(start, end));
         return (1);
      endsub;
      function myNodePairFilter3(node[*] $, ordering[*]);
         if(ordering[1] EQ . OR ordering[2] EQ .) then return (1);
         if(ordering[1] LT ordering[2]) then
            return (node[1] LT node[2]);
         return (1);
      endsub;
   endsource;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.myRoutines"}; run;
   fcmpact.addRoutines /
      appendTable = true,
      saveTable   = true,
      funcTable   = {name="myRoutines", caslib="casuser", replace=true},
      package     = "myPackage",
      routineCode = myFilter;
   run;
quit;

proc network
   graph            = &graphId
   nodesQuery       = mycas.nodesQ
   linksQuery       = mycas.linksQ;
   nodesQueryVar
      vars          = (type ordering)
      varsMatch     = (type);
   linksQueryVar
      vars          = (constrain)
      varsMatch     = ();
   patternMatch
      LinkPairFilter= myLinkPairFilter3(l.from, l.start, l.end, lQ.constrain)
      nodePairFilter= myNodePairFilter3(n.node, nQ.ordering)
      outMatchNodes = mycas.OutMatchNodes
      outMatchLinks = mycas.OutMatchLinks
      queryKey      = querykey
      maxMatches    = 1000;
run;

title "Cliques of Inmates: Method 1";
proc print data=mycas.outMatchLinks(obs=50); by querykey match; run;
proc print data=mycas.outMatchNodes(obs=50); by querykey match; run;
title;

%visualizeMatches(query_3_0_match, queryKey="0", num=1, layout=sfdp);
%visualizeMatches(query_3_1_match, queryKey="1", num=3, layout=sfdp);
%visualizeMatches(query_3_3_match, queryKey="3", num=3, layout=sfdp);


/** Example 4: **/
/* Find "cliques" using patternMatch (preprocess) + clique */
/* An alternative approach to arrive at the answer of Example 3 */
data mycas.nodesQ;
   infile datalines dsd;
   length node $12 type $12;
   input node $ type $ ordering;
   datalines;
inmate1, INMATE,1
inmate2, INMATE,2
cellA, CELL,.
;
data mycas.linksQ;
   infile datalines dsd;
   length from $12 to $12;
   input from $ to $;
   datalines;
inmate1, cellA
inmate2, cellA
;

/** Define FCMP Functions **/
proc cas;
   source myFilter;
      function myLinkPairFilter4(start[*], end[*]);
         return (hasOverlap(start, end));
      endsub;
      function myNodePairFilter4(node[*] $, ordering[*]);
         if(ordering[1] EQ . OR ordering[2] EQ .) then return (1);
         if(ordering[1] LT ordering[2]) then
            return (node[1] LT node[2]);
         return (1);
      endsub;
   endsource;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.myRoutines"}; run;
   fcmpact.addRoutines /
      appendTable = true,
      saveTable   = true,
      funcTable   = {name="myRoutines", caslib="casuser", replace=true},
      package     = "myPackage",
      routineCode = myFilter;
   run;
quit;

proc network
   graph            = &graphId
   nodesQuery       = mycas.nodesQ
   linksQuery       = mycas.linksQ;
   nodesQueryVar
      vars          = (type ordering)
      varsMatch     = (type);
   patternMatch
      LinkPairFilter= myLinkPairFilter4(l.start, l.end)
      nodePairFilter= myNodePairFilter4(n.node, nQ.ordering)
      outMatchNodes = mycas.outMatchNodes
      outMatchLinks = mycas.outMatchLinks
      maxMatches    = 100000;
run;

data mycas.inmatePairs;
   merge mycas.outMatchNodes(where=(nodeQ="inmate1") rename=(node=from))
         mycas.outMatchNodes(where=(nodeQ="inmate2") rename=(node=to));
   by match;
   keep from to;
run;


proc network
   links            = mycas.inmatePairs
   ;
   clique
      out           = mycas.outCliques
      minNodeWeight = 3
      maxCliques    = ALL;
      ;
run;

%joinNodeInfo(outCliques, inmates, node, inmateId, name, (firstName || ' ' || lastName));
proc sort data=mycas.outCliques out=outCliques; by clique node; run;
title "Cliques of Inmates: Method 2";
proc print data=outCliques(obs=50);
   by clique;
   label node="InmateId";
run;
title;


%macro unloadGraph();
   %if (%symexist(graphId)) %then %do;
      proc cas;
         network.unloadGraph result=r /
            display={excludeAll=TRUE} graph = &graphId;
      run;
      %symdel graphId;
   %end;
%mend unloadGraph;
proc cas;
   %unloadGraph();
quit;


