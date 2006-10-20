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
  { $INCLUDE : 'alterl.int' }
  { $INCLUDE : 'graphpak.int' }
  { $INCLUDE : 'sldetc.int' }
  { $INCLUDE : 'macexec.int' }
  { $INCLUDE : 'macpict.int' }

  program mac ( input, output );

     USES vbpas;

     USES option;

     USES getparam;

     USES utility;

     USES sfpas;

     USES dialog;

     USES ldb;

     USES execute;

     USES dspas;

     USES alterl;

     USES sldetc;

     USES macexec;

     USES macpict;

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
      buf, msg1, msg2  : lstring(80);


  (********************************************************)

  procedure mac_initialize;

  begin
    color := 1;
    screen(4); colors(0,color);
    skipfield := [6];
    height := 240;
    color1 := 3;
    rtype  := 2;
    saved  := true;
    for i := 1 to 4 do
      [clr[i] := skeleton^[i+14];
       ndon[i] := skeleton^[i+18];
       ndoff[i] := skeleton^[i+22];
       fill[i] := skeleton^[i+26];];
    if name <> null  then
      chartinfo (2, first, skeleton^ );
      else [chartinfo (3, first, skeleton^ );
	    first_create := true;
	    format ( inkey, current, first ); ];
    if (name <> null) and (not (inkey in [4,5])) then
      begin
	skelemac ( color, skeleton^ );
	picture  ( first, skeleton^ );
	reduce	 ( rtype, color);
      end;
    promptupd := 2;
    msg1 := null;
    msg2 := null;
    if ( not update ) and ( name <> null ) and (not (inkey in [4,5]))   then
    begin
      while first <> nil  do  delete (first);
      initialize ( first );
      first_create := true;
      chartinfo ( 3, first, skeleton^ );
      msg1 := messages^[19];
      msg2 := messages^[20];
      promptupd := 1;
    end;
  end;

  (********************************************************)

  procedure mac_update;

  begin
    if msg1 = messages^[19]  then
      begin
       if inkey in [4,10]  then  inkey := 0;
       if inkey in [7,41]  then
	begin
	  msg1 := null;
	  msg2 := null;
	end;
      end;
  end;

  (********************************************************)

  begin


     pname := 'mac.ctl';
     gtype := 'mac';
     pltype := 'sld';
     cname := 'Resource';
     sldtype := 'sldmac';

     get_equip;
     get_parameter ( pname );

   repeat
     select;
     if not endflag then
     begin

       dsinit;

       if name <> null then load_chart ( name, first )
		       else initialize ( first );

	inkey := 0;
	mac_initialize;

	current := first;
	current_node  := current^.etype;
	  while inkey <> 1 do
	    begin
	      inkey := 0;
	      incom ( 22, msg1, msg2, -2, rtype, 0, 0, 0, 4, 0, 1, 1,
		      1, 1, 1, 1, 1, status, buffer, length, inkey );

	      mac_update;

		 perform2 ( inkey, first, name, skeleton^ );
		 perform  ( inkey, current, current_node, first )
	    end;
    end
    until endflag;
  end.
