/* Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0 */

option casport=<your_cas_port> cashost=<your_cas_url>;
cas;
caslib _all_ assign;

options caslib=casuser;

/*************************************/
/* Create the organization structure */
/*************************************/

data employees;
  infile datalines dsd;
  input 
    employee_id : 4.
    full_name : $32.
    manager_id : 4.
  ;
  datalines;
1, 'Michael North', .
2, 'Megan Berry', 1
3, 'Sarah Berry', 1
4, 'Zoe Black', 1
5, 'Tim James', 1
6, 'Bella Tucker', 2
7, 'Ryan Metcalfe', 2
8, 'Max Mills', 2
9, 'Benjamin Glover', 2
10, 'Carolyn Henderson', 3
11, 'Nicola Kelly', 3
12, 'Alexandra Climo', 3
13, 'Dominic King', 3
14, 'Leonard Gray', 4
15, 'Eric Rampling', 4
16, 'Piers Paige', 7
17, 'Ryan Henderson', 7
18, 'Frank Tucker', 8
19, 'Nathan Ferguson', 8
20, 'Kevin Rampling', 8 
;
run;
	
/* Utility macros */
%macro isBlank( param ) ;
    %sysevalf( %superq( param ) =, boolean )
  %mend ;
  
%macro recursive(id =, iter = );
  %if %isblank(&id) %then %do;
    %put %str(E)RROR: Must pass in a PK value.;
    %return;
  %end;

  %if %isblank(&iter) %then %do;
    proc sql;
      create table lev0 as
        select    employee_id
                , full_name
                , manager_id
        from      employees
        where     employee_id = &id
      ;
    quit;

    %if &sqlobs = 0 %then %do;
      %put %str(E)RROR: No entries found using ID = &id;
      %return;
    %end;

    %if %sysfunc(exist(results)) %then %do;
      /* Clear out old version should it exist */
      proc delete data = results;
      run;
    %end;

    data results;
      set lev0;
    run;

    %let iter = 1;
  %end;

  proc sql;
    create table lev&iter as
      select      employee_id
                , full_name
                , manager_id
      from        employees
      where       manager_id in(
        select    distinct employee_id
        from      lev%eval(&iter - 1))
    ;
  quit;

  %if &sqlobs %then %do;
    proc append
      base = results
      data = lev&iter
    ;
    run;
    
    %recursive(id = &id, iter = %eval(&iter + 1 ));
  %end;

%mend;

/* Call the macro to find all employees who report to employee id 2 (Megan Barry) */
%recursive(id = 2);