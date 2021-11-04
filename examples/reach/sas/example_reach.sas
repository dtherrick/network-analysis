option casport=13404 cashost="orgrd061.unx.sas.com";
cas;

libname mycas cas caslib="CASUSER(daherr)";

data employees;
  infile datalines dsd;
  input 
    employee_id
    full_name : $32.
    manager_id
  ;
  datalines;
1, "Michael North", .
2, "Megan Berry", 1
3, "Sarah Berry", 1
4, "Zoe Black", 1
5, "Tim James", 1
6, "Bella Tucker", 2
7, "Ryan Metcalfe", 2
8, "Max Mills", 2
9, "Benjamin Glover", 2
10, "Carolyn Henderson", 3
11, "Nicola Kelly", 3
12, "Alexandra Climo", 3
13, "Dominic King", 3
14, "Leonard Gray", 4
15, "Eric Rampling", 4
16, "Piers Paige", 7
17, "Ryan Henderson", 7
18, "Frank Tucker", 8
19, "Nathan Ferguson", 8
20, "Kevin Rampling", 8 
;
	
data linkSetIn;
	infile datalines dsd;
	input from to;
	datalines;
1, 2
1, 3
1, 4
1, 5
2, 6
2, 7
2, 8
2, 9
3, 10
3, 11
3, 12
3, 13
4, 14
4, 15
7, 16
7, 17
8, 18
8, 19
8, 20 
;
	
data NodeSubSetIn;
   input node reach;
   datalines;
2 1
;
	
data mycas.linkSetIn;
	set linkSetIn;
	run;
	
data mycas.NodeSubSetIn;
	set NodeSubSetIn;
	run;
	
proc cas;
	loadactionset "network";
quit;

proc cas;
   network.reach result=r status=s /
      direction     = "directed"
      links         = {name = "LinkSetIn"}
      nodessubset   = {name = "NodeSubSetIn"}
      outReachNodes = {name = "ReachNodes", replace=true}
      outReachlinks = {name = "ReachLinks", replace=true}
      outCounts     = {name = "ReachCounts", replace=true}
      maxreach      = 1;
   run;
   print r.ProblemSummary; run;
   print r.SolutionSummary; run;
   action table.fetch / table = "ReachNodes" sortBy = {"reach", "node"}; run;
   action table.fetch / table = "ReachLinks" sortBy = {"reach", "from", "to"}; run;
   action table.fetch / table = "ReachCounts" sortBy = {"reach", "node"}; run;
quit;