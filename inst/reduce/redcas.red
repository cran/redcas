%% $Id: redcas.red,v 1.2 2024/09/03 17:16:29 mg Exp $

%%  Purpose: The file contains REDUCE functions for the redcas package
%%         itoa: converts a number to a string
%% array2flatls: converts an array to a flattened list
%%        asltx: calls arrayltx or exprltx depending on the object type
%%     arrayltx: converts the flattened list to LaTeX
%%      exprltx: converts an expression to LaTeX
%% asltx_marker: write start label, call asltx, write end label
%%    Note: for making lisp functions available, symbolic operator is sufficient
%%    Note: var eq "val" fails in an algebraic procedure always returning false. Need to use
%%          lisp(var = "val")

%% +++TODO+++
%% 1. modify ltxtm_array to allow specifying fancy or just rely on the switch? DROP, same as 2
%% 2. rename ltxtm_array to arrayltx and add mode=nat|fancy|rlfi, default nat, check if
%%    fancy/rlfi is on and avoid changing it. DONE 2024-03-29 but w/o rlfi
%% 3. if 2. rename ltxtm_array2ls to array2flatls. DONE 2024-03-29
%% 4. move on/off fancy out of the loop. DONE 2024-03-29
%% 5. use id2string to get the name of the array and drop the aname parameter. DONE 2024-03-29
%% 6. for rlfi, need to use the mathstyle and user may need to use defid, defindex
%% 7. investigate using a list for variable # arguments (possible issue with not recognizing array

%% 8. use \{} when writing bmath/emath? FANCY converts \ to \textbackslash! and {} to
%%    \{\}. There is a symbolic operator tex_string which renders a TeX string as
%%    is. Works perfectly for CSL, but for PSL must first load tmprint and then we have a
%%    bizarre command prompt and fancy is automatically turned on. Need to look at
%%    setpchar. Fixed by creating a copy of tmprint.red and making one minor change. DONE 2024-04-04
%% $Log: redcas.red,v $
%% Revision 1.2  2024/09/03 17:16:29  mg
%% Major update
%% 1. Solved issues with asltx and PSL by a slightly modified version of tmprint.red.
%%    redcas.red includes this if running PSL
%% 2. added lisp_dialect to retrieve the dialect (differs for CSL and PSL)
%% 3. added swget to retrive state of a switch
%% 4. added swtoggle to toggle switch
%% 5. renamed ltxtm to asltx and added mode and name parameters for handling output
%%    mode and optional name for expressions
%% 6. renamed ltxtm_array to arrayltx adding mode and dropping name
%% 7. added exprltx for handling expressions
%% 8. added asltx_marker to write start label, call asltx, write end label
%% 9. renamed ltxtm_array2ls to array2flatls
%% 10. Improved function headers
%%

%% assist has the array functions:
%%     array_to_list converts an array to a (nested, unless 1-D) list
%%     list_to_array converts an appropriately formatted list to an array
%%     ls.n returns nth element of list ls
%% and also n-dim vector operations which do not exist for arrays. Also has show, mkset +
%% related operations.
load_package assist ;

%% some functions needed from symbolic mode
symbolic operator concat ;    %% concatenate 2 strings
symbolic operator gettype ;   %% distinguishing arrays from "simple" expressions
symbolic operator arrayp ;    %% array predicate
symbolic operator id2string ; %% operator name as string ;
symbolic operator tex_string ;%% render string without quoting /, { or }
symbolic operator onoff ;     %% required by toggle_switch

%% function to determine the lisp version
%%  Args: none
%% Value: 'psl or 'csl 
symbolic procedure lisp_dialect ;
   begin scalar dialect ;
      if 'psl memq lispsystem!* then dialect:='psl
      else if 'csl memq lispsystem!* then dialect:='csl
      else rederr "Unknown lisp dialect.";
      return(dialect) ;
   end ;
symbolic operator lisp_dialect ;

%% For PSL only we need to call a modified version of tmprint in order to
%%   1. avoid loading the package and turning on TeXmacs prompts.
%%   2. set a long linelength to avoid wrapping
if lisp_dialect() = 'psl then
<<
   system "echo Running in $PWD" ;
   symbolic operator linelength;
   linelength(30000) ;
   out "/dev/null" ;
   off msg ;
   tmprintpslpath:=lisp(getenv("TMPRINT_PSL_PATH")) ;
   in <<tmprintpslpath>> $
   on msg;
   out t ;
   off fancy ; %% because loading tmprint-psl.red turns it on
>> ;

%% Function: swget
%%  Purpose: retrieve the current setting of a switch
%% Args:
%%        s: switch: as either id, quoted id or string
%%    Value: boolean: t is ON
symbolic procedure swget (s) ;
   eval intern list2string('!* . explode2 s) ;
symbolic operator swget ;

symbolic operator onoff ;
%% Function: swtoggle
%%  Purpose: toggle the setting of a switch
%% Args:
%%        s: switch: as either id, quoted id or string
%%    Value: t is ON, 0 is off
symbolic procedure swtoggle (s) ;
   begin ;
      if idp s then onoff(s, not swget(s))
      else rederr "Argument to swtoggle must be an identifier" ;
      return swget(s) ;
   end ;
symbolic operator swtoggle ;

%% Function: asltx
%%  Purpose: to write an object as latex output using FANCY. This first determines the
%%           object type and then calls a corresponding function.
%% Args:
%%    thing: an object to be typeset
%%  mathenv: string naming a LaTeX math environment in which to enclose each array
%%           element. If empty no math environment is written
%%     mode: print mode: nat|fancy(|rlfi), if not specified, defaults to nat. fancy and
%%           latex switches override
%%    named: if true, print as name := value. arrays are always printed with
%%           name(indices). In addition not needed as id2string returns array name as
%%           string. This does not work with expressions.
algebraic procedure asltx (thing, math, mode, name) ;
   begin scalar type ;
      if gettype(thing) = 'array then arrayltx(thing, math, mode)
      else if gettype(thing) = 'form then exprltx(thing, math, mode, name)
   end ;

%% Function: exprltx
%%  Purpose: print and expression using the specified mode and wrapping in specific maths
%%           environment
%%     xprs: name of expression
%%  mathenv: string naming a LaTeX math environment in which to enclose each array
%%           element. If empty no math environment is written
%%     mode: print mode: nat|fancy(|rlfi), if not specified, defaults to nat. fancy and
%%           latex switches override
%%    named: if true, print as name := value
%%    Value: none. Called for side effect of printing

algebraic procedure exprltx(xprs, math, mode, name) ;
   begin scalar bmath, emath, aname:="", toggle_fancy, lpfix:="", lsfix:="";
      %% write "DEBUG: xprs:", xprs, " math: ", math, " mode: ", mode, " name:  ", name ;
      
      %% set bmath and emath ;
      if lisp(math = "" or math = "$") then <<bmath:=""; emath:="" >>
      else if lisp(math neq "$") then <<
          bmath:=concat("\begin{", concat(math, "}")) ;
          emath:=concat("\end{", concat(math, "}"))>> ;
      %% write "DEBUG: ", bmath, emath ;
      
      %% determine which mode is to be used and whether we need to toggle
      if lisp(mode = "") then mode:="nat" 
      else if lisp(mode = "fancy") then <<
	 toggle_fancy:=if lisp(!*fancy) then nil else t 
      >>
      else if lisp(mode neq "nat") then rederr "Argument 3 must be nat, fancy or rlfi." ;
      %% write "mode: ", mode, "toggle_f: ", toggle_fancy ;
      
      %% construct prefix ($name := ) and suffix ($) for the line if not blank
      %% needs to be done before turning on fancy
      if lisp(name neq "") then lpfix:=concat(name, " := ") ;
      %% write "DEBUG: lpfix: ", lpfix, " lsfix: ", lsfix ;
      if lisp(math = "$") then <<lpfix:=concat(math, lpfix);lsfix:=math>> ;
      %% write "DEBUG: lpfix: ", lpfix, " lsfix: ", lsfix ;

      %% toggle switches on if necessary
      if lisp(mode = "fancy") and toggle_fancy then on fancy, fancy_tex ;

      if lisp(bmath neq "") then
	 if lisp(!*fancy) then tex_string(bmath) else write bmath;
      %% writing l[ps]fix when "" generates a spurious \mathrm{}, so avoid this. Note that
      %% if lpfix is "" then so is lsfix
      if lisp(lpfix = "") then write xprs else
 	 if lisp(lsfix = "") then write lpfix, xprs
      	 else write lpfix, xprs, lsfix ;
      if lisp(emath neq "") then
	 if lisp(!*fancy) then tex_string(emath) else write emath;

      %% toggle switches off if necessary
      if lisp(mode = "fancy") and toggle_fancy then off fancy, fancy_tex
   end ;

%% Function: itoa
%%  Purpose: convert an integer to a string
%%        n: integer
%%    Value: integer as a string
algebraic procedure itoa(n) ;
   begin ;
      if numberp n then return (lisp(list2string(explode(n))))
      else rederr(concat(n, " is not a number."));
   end ;

%% Function: array2flatls
%%  Purpose: convert an array to a flat list
%%   athing: name of array
%%    Value: a flat list representation of the array
%% TODO: use depth instead of len(len())?
listproc array2flatls (arrx) ;
   begin scalar xls, xlen ;
      if not arrayp(arrx) then rederr "Argument x is not an array" ;
      xls:=array_to_list(arrx) ;		%% array_to_list is from ASSIST
      xlen:=length(length(arrx))-1 ;
      for i:=1:xlen do xls:=for each el in xls join el ;
      return xls ;
   end ;

%% Function: arrayltx
%%  Purpose: print all elements of an array. If NERO is on, zeroes are ignored
%%    arrax: name of array
%%  mathenv: string naming a LaTeX math environment in which to enclose each array
%%           element. If empty no math environment is written
%%     mode: print mode: nat|fancy(|rlfi), if not specified, defaults to nat. fancy and
%%           latex switches override

%%    Value: none. Called for side effect of printing
algebraic procedure arrayltx (arrx, math, mode) ;
   begin scalar adim, cdim, a2ls, bmath, emath, aname, toggle_fancy, toggle_rlfi ;
      if not arrayp(arrx) then rederr "Argument 1 is not an array" ;
      a2ls:=array2flatls(arrx) ; %% convert array to flat list
      adim:=length(arrx) ;  	 %% list containing length of each dimension
      cdim:=length(adim)-1 ;	 %% upper limit for arr!*idx array
      aname:=id2string(arrx) ;

      %% we cannot rely on nero because were are writing the indices explicitly and these
      %% can be non-zero for a zero value.
      przero:= lisp not !*nero ;
      %% if przero then write "przero is t" else write "przero is nil" ;

      if lisp(math = "") then <<bmath:=""; emath:="" >>
       else <<
          bmath:=concat("\begin{", concat(math, "}")) ;
          emath:=concat("\end{", concat(math, "}"))>> ;
      %% write bmath, " / ", emath ;

      %% determine which mode is to be used and whether we need to toggle
      if lisp(mode = "") then mode:="nat" 
      else if lisp(mode = "fancy") then <<
	 toggle_fancy:=if lisp(!*fancy) then nil else t 
      >>
	 %% else if lisp(mode = "rlfi") then <<
	 %%   toggle_rlfi:=if lisp(!*latex) then nil else t 
	 %% >>
      else if lisp(mode neq "nat") then rederr "Argument 3 must be nat, fancy or rlfi." ;
      
      %% toggle switches on if necessary
      if lisp(mode = "fancy") and toggle_fancy then on fancy, fancy_tex
      else if lisp(mode = "rlfi") and toggle_rlfi then on latex, lasimp ;

      %% write "fancy: ", lisp(!*fancy) ;

      %% write "Array ", arrx, " with dimensions ", adim ;
      array arr!*idx(cdim) ; %% to hold the current value of the indices (init to 0)
      for i:=1:length(a2ls) do
       	 << idx:="" ;		%% construct the string of indices and print
            for i:=0:cdim do
      	       <<idx:=concat(idx, itoa(arr!*idx(i))) ;
	       	  if i<cdim then idx:=concat(idx, ",") >> ;
	    if przero or a2ls.i neq 0 then << %% tex_string always writes in fancy
	       if lisp(bmath neq "") then
		  if lisp(!*fancy) then tex_string(bmath) else write bmath;
	       write aname, "(", idx, ") := ", a2ls.i ;
	       if lisp(emath neq "") then
 		  if lisp(!*fancy) then tex_string(emath) else write emath;
	    >> ;
	    
	    %% increment the counters. When one reaches the top, reset it to zero and add
	    %% one to the counter to the left
	    j:=cdim ;
	    break:=0 ;
	    while break = 0 do <<
 	       %% write "j: ", j, " inc: ", break, " adim.(j+1): ", adim.(j+1), " idx(j): ", arr!*idx(j) ;
	       arr!*idx(j):=arr!*idx(j) + 1 ;
	       if arr!*idx(j) = adim.(j+1) then <<  %% j+1 because adim is a list
		  arr!*idx(j):=0;
 	       	  if j = 0 then break:=1	%% because there is no further index
		  else j:=j - 1 >>
	       else break:=1 ;
	    >> ;
	 >> ;
      %% delete arr!*idx
      clear arr!*idx ;
      %% toggle switches off if necessary
      if lisp(mode = "fancy") and toggle_fancy then off fancy, fancy_tex
      else if lisp(mode = "rlfi") and toggle_rlfi then off latex, lasimp ;
   end ;

%% Function: asltx_marker
%%  Purpose: write start label, call asltx, write end label
%% Args:
%%    thing: object for asltx to display
%%     math: math environment for asltx
%%     mode: reduce output mode for asltx
%%     name: name for asltx
%%    label: label for the marker
algebraic procedure asltx_marker (thing,  math, mode, name, label) ;
   begin ;
      write "##START ", label;
      asltx(thing,  math, mode, name) ;
      write "##END ", label;
   end ;

%% obligatory for included files
;end;
