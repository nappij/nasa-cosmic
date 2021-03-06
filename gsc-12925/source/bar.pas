  { $INCLUDE : 'compile.inc' }
  { $INCLUDE : 'vbpas.int' }
  { $INCLUDE : 'option.int' }
  { $INCLUDE : 'getparam.int' }
  { $INCLUDE : 'utility.int' }
  { $INCLUDE : 'sfpas.int' }
  { $INCLUDE : 'dialog.int' }
  { $INCLUDE : 'ldb.int'     }
  { $INCLUDE : 'execute.int' }
  { $INCLUDE : 'dspas.int' }
  { $INCLUDE : 'graphpak.int' }
  { $INCLUDE : 'sldetc.int' }
  { $INCLUDE : 'barpict.int' }
  { $INCLUDE : 'barexec.int' }

  program bar ( input, output );

     USES vbpas;

     USES option;

     USES getparam;

     USES utility;

     USES sfpas;

     USES dialog;

     USES ldb;

     USES execute;

     USES dspas;

     USES sldetc;

     USES barpict;

     USES barexec;

  var
      pname	       : lstring(14);
      length	       : byte;
      inkey	       : byte;
      current_node     : byte;
      current, first   : entity;
      status	       : mode;
      buffer	       : lstring(127);
      reply	       : char;
      i, k	       : byte;
      msg1,msg2        : lstring(80);

 (********************************************************)

  procedure bar_initialize;

  begin
   saved := true;
   color := 1;
   color1 := 3;
   color2[1]   :=  1;  color2[2]   := 2;
   fill2[1]    := 15;  fill2[2]    := 9;
   pattern2[1] :=  1;  pattern2[2] := 0;
   rtype := 2;
   screen(4); colors(0,color);
   skipfield := [7];
   height := 240;
   msg1 := null;   msg2 := null;
   promptupd := 2;

   if name <> null then
      begin
	chartinfo (2, first, skeleton^ );
	skelebar  (   color, skeleton^ );
	picture   (   first, skeleton^ );
	reduce (rtype, color);
      end
   else begin
	chartinfo (3, first, skeleton^ );
	first_create := true;
	format ( inkey, current, first );
   end; (* if name <> null *)
   if (not update) and (name <> null) and (not (inkey in [4,5])) then
       begin
	 while first <> nil do delete (first);
	 initialize (first);
	 first_create := true;
	 chartinfo (3, first, skeleton^ );
	 msg1 := messages^[19];
	 msg2 := messages^[20];
	 promptupd := 1;
       end (* if not update *)
  end;	   (* bar_inititalize *)

  (********************************************************)

  procedure bar_update;
  begin
      if msg1 = messages^[19] then begin
	 if inkey in [4,10] then
	    inkey := 0 ;
	 if inkey in [7,41] then begin
	    msg1 := null;
	    msg2 := null;
	 end;
      end; (* if msg1 *)
  end;

 (********************************************************)

  begin


     pname  := 'bar.ctl';
     gtype  := 'bar';
     pltype := 'sld';
     cname  := 'Bar / Line';
     sldtype := 'sldbar' ;

     get_equip;
     get_parameter ( pname );

     repeat
	select;
	if not endflag then
	  begin
	     dsinit;
	     if name <> null then load_chart ( name, first )
			     else initialize ( first );

             inkey := 0 ;
	     bar_initialize;
	     current := first;
	     current_node  := current^.etype;

	     while inkey <> 1 do
		begin
		  inkey := 0;
		  incom (22, msg1, msg2, -2, rtype, 0, 0, 0, 4, 0, 1, 1,
			 1, 1, 1, 1, 1, status, buffer, length, inkey);

		  bar_update;

		  perform2 ( inkey, first, name, skeleton^);
		  perform  ( inkey, current, current_node, first );
		end;
	 end
     until endflag;
  end.

