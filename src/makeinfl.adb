-- WORDS, a Latin dictionary, by Colonel William Whitaker (USAF, Retired)
--
-- Copyright William A. Whitaker (1936–2010)
--
-- This is a free program, which means it is proper to copy it and pass
-- it on to your friends. Consider it a developmental item for which
-- there is no charge. However, just for form, it is Copyrighted
-- (c). Permission is hereby freely given for any and all use of program
-- and data. You can sell it as your own, but at least tell me.
--
-- This version is distributed without obligation, but the developer
-- would appreciate comments and suggestions.
--
-- All parts of the WORDS system, source code and data files, are made freely
-- available to anyone who wishes to use them, for whatever purpose.

with Text_IO;
with Strings_Package; use Strings_Package;
with latIn_File_names; use latIn_File_names;
with inflections_package; use inflections_package;
with IO_Exceptions;
procedure makeinfl is
   package Integer_IO is new Text_IO.Integer_IO(Integer);
   use Text_IO;
   use Integer_IO;
   use stem_key_type_io;
   use inflection_record_io;
   use quality_record_io;
   use ending_record_io;
   use age_type_io;
   use frequency_type_io;
   use lel_section_io;

   porting : constant Boolean := True;    --FALSE for WAKEINFL;

   m : Integer := 0;
   n1, n2, n3, n4, n5 : Integer := 0;

   Output : Text_IO.File_Type;
   inflections_sections_file : lel_section_io.File_Type;

   procedure file_inflections_sections is
      --  Reads the INFLECTS. file and prepares an inflections list
      --  Then it Writes that list into an array
      --  Loads the inflection array into a file for later retrieval
      inflections_file : Text_IO.File_Type;
      inflections_sections_file : lel_section_io.File_Type;
      ir : inflection_record;
      line : String(1..100) := (others => ' ');
      last, l : Integer := 0;
      sn : ending_size_type := ending_size_type'First;
      sx : Character := ' ';

      type inflection_item;
      type inflection_list is access inflection_item;

      type inflection_item is
         record
            ir   : inflection_record;
            succ : inflection_list;
         end record;

      type latin_inflections is array (Integer range 0..max_ending_size,
                                       Character  range ' '..'z') of inflection_list;
      null_latin_inflections : constant latin_inflections := (others => (others => null));

      l_i : latin_inflections := null_latin_inflections;

      lel : lel_section := (others => null_inflection_record);
      j1, j2, j3, j4, j5 : Integer := 0;

      procedure null_lel is
      begin
         for i in lel'Range loop
            lel(i) := null_inflection_record;
         end loop;
      end null_lel;

      procedure load_inflections_list is
         --  Takes the INFLECT. file and populates the L_I list of inflections
         --  indexed on ending size and last letter of ending
      begin
         Put_Line("Begin  LOAD_INFLECTIONS_LIST");
         number_of_inflections := 0;

         l_i := null_latin_inflections;
         Open(inflections_file, In_File, inflections_full_name);
         Text_IO.Put("INFLECTIONS file loading");
         while not End_Of_File(inflections_file)  loop

            read_a_line:
            begin
               Get_Non_Comment_Line (inflections_file, line, last);

               if last > 0  then
                  Get(line(1..last), ir, l);
                  sn := ir.ending.size;
                  if sn = 0  then
                     sx := ' ';
                  else
                     sx := ir.ending.suf(sn);
                  end if;
                  l_i(sn, sx) := new inflection_item'(ir, l_i(sn, sx));
                  number_of_inflections := number_of_inflections + 1;
                  --TEXT_IO.PUT(INTEGER'IMAGE(NUMBER_OF_INFLECTIONS) & "  "); INFLECTION_RECORD_IO.PUT(IR); NEW_LINE;
               end if;
            exception
               when Constraint_Error | IO_Exceptions.Data_Error  =>
                  Put_Line("****" & line(1..last));
            end read_a_line;

         end loop;
         Close(inflections_file);
         Put_Line("INFLECTIONS_LIST LOADED   " & Integer'Image(number_of_inflections));
      end load_inflections_list;

      procedure list_to_lel_file  is
         --  From ILC (=L_I) list of inflections, prepares the LEL inflections array
         ilc : latin_inflections := l_i;
      begin
         Create(inflections_sections_file, Out_File, inflections_sections_name);

         null_lel;
         ilc := l_i;                              --  Resetting the list to start over
         while ilc(0, ' ') /= null  loop
            j5 := j5 + 1;
            lel(j5) := ilc(0, ' ').ir;
            ilc(0, ' ') := ilc(0, ' ').succ;
         end loop;
         Write(inflections_sections_file, lel, 5);
         n5 := j5;

         null_lel;
         ilc := l_i;                              --  Resetting the list to start over
         for ch in Character range 'a'..'z'  loop
            for n in reverse 1..max_ending_size  loop
               while ilc(n, ch) /= null  loop
                  if   not
                    (ilc(n, ch).ir.qual.pofs = pron  and then
                       (ilc(n, ch).ir.qual.pron.decl.which = 1  or
                          ilc(n, ch).ir.qual.pron.decl.which = 2))
                  then
                     if ch in inflections_section_1  then
                        j1 := j1 + 1;
                        lel(j1) := ilc(n, ch).ir;
                     end if;
                  end if;
                  ilc(n, ch) := ilc(n, ch).succ;
               end loop;
            end loop;
         end loop;
         Write(inflections_sections_file, lel, 1);
         n1 := j1;

         null_lel;
         ilc := l_i;                              --  Resetting the list to start over
         for ch in Character range 'a'..'z'  loop
            for n in reverse 1..max_ending_size  loop
               while ilc(n, ch) /= null  loop
                  if   not
                    (ilc(n, ch).ir.qual.pofs = pron  and then
                       (ilc(n, ch).ir.qual.pron.decl.which = 1  or
                          ilc(n, ch).ir.qual.pron.decl.which = 2))
                  then
                     if ch in inflections_section_2  then
                        j2 := j2 + 1;
                        lel(j2) := ilc(n, ch).ir;
                     end if;
                  end if;
                  ilc(n, ch) := ilc(n, ch).succ;
               end loop;
            end loop;
         end loop;
         Write(inflections_sections_file, lel, 2);
         n2 := j2;

         null_lel;
         ilc := l_i;                              --  Resetting the list to start over
         for ch in Character range 'a'..'z'  loop
            for n in reverse 1..max_ending_size  loop
               while ilc(n, ch) /= null  loop
                  if   not
                    (ilc(n, ch).ir.qual.pofs = pron  and then
                       (ilc(n, ch).ir.qual.pron.decl.which = 1  or
                          ilc(n, ch).ir.qual.pron.decl.which = 2))
                  then
                     if ch in inflections_section_3  then
                        j3 := j3 + 1;
                        lel(j3) := ilc(n, ch).ir;
                     end if;
                  end if;
                  ilc(n, ch) := ilc(n, ch).succ;
               end loop;
            end loop;
         end loop;
         Write(inflections_sections_file, lel, 3);
         n3 := j3;

         null_lel;
         ilc := l_i;                              --  Resetting the list to start over
         for ch in Character range 'a'..'z'  loop
            for n in reverse 1..max_ending_size  loop
               while ilc(n, ch) /= null  loop
                  if   not
                    (ilc(n, ch).ir.qual.pofs = pron  and then
                       (ilc(n, ch).ir.qual.pron.decl.which = 1  or
                          ilc(n, ch).ir.qual.pron.decl.which = 2))
                  then
                     if ch in inflections_section_4 then
                        j4 := j4 + 1;
                        lel(j4) := ilc(n, ch).ir;
                     end if;
                  end if;
                  ilc(n, ch) := ilc(n, ch).succ;
               end loop;
            end loop;
         end loop;

         --  Now Put the PACK in 4            --  Maybe it should be in 5 ????
         ilc := l_i;                              --  Resetting the list to start over
         for ch in Character range 'a'..'z'  loop
            for n in reverse 1..max_ending_size  loop
               while ilc(n, ch) /= null  loop
                  if ilc(n, ch).ir.qual.pofs = pron  and then
                        (ilc(n, ch).ir.qual.pron.decl.which = 1  or
                           ilc(n, ch).ir.qual.pron.decl.which = 2)
                  then  --  2 no longer PACK
                     j4 := j4 + 1;
                     lel(j4) := ilc(n, ch).ir;
                  end if;
                  ilc(n, ch) := ilc(n, ch).succ;
               end loop;
            end loop;
         end loop;
         Write(inflections_sections_file, lel, 4);
         n4 := j4;

         Close(inflections_sections_file);
      end list_to_lel_file;

   begin
      load_inflections_list;

      Text_IO.Set_Col(33);
      Text_IO.Put("--  ");
      Integer_IO.Put(number_of_inflections);
      Text_IO.Put_Line(" entries    --  Loaded correctly");

      list_to_lel_file;                     --  Load arrays to file
      Text_IO.Put_Line("File INFLECTS.SEC  --  Loaded");

   exception
      when others =>
         Text_IO.Put_Line("Exception in FILE_INFLECTIONS_SECTIONS");
   end file_inflections_sections;

begin

   Put_Line("Produces INFLECTS.SEC file from INFLECTS.");

   file_inflections_sections;

   if not porting  then
      Put_Line("using FILE_INFLECTIONS_SECTIONS, also produces INFLECTS.LIN file");

      Create(Output, Out_File, "INFLECTS.LIN");
   end if;

   establish_inflections_section;

   lel_section_io.Open(inflections_sections_file, In_File,
                       inflections_sections_name);

   if not porting then
      for i in bel'Range loop                     --  Blank endings
         if  bel(i) /= null_inflection_record  then
            m := m + 1;
            Put(Output, bel(i).qual);
            Set_Col(Output, 50);
            Put(Output, bel(i).key, 1);
            Set_Col(Output, 52);
            Put(Output, bel(i).ending);
            Set_Col(Output, 62);
            Put(Output, bel(i).age);
            Set_Col(Output, 64);
            Put(Output, bel(i).freq);
            New_Line(Output);
         end if;
      end loop;
   end if;

   for n in 1..4  loop
      Read(inflections_sections_file, lel, lel_section_io.Positive_Count(n));

      if not porting then
         for i in lel'Range loop                     --  Non-blank endings
            if  lel(i) /= null_inflection_record  then
               m := m + 1;
               Put(Output, lel(i).qual);
               Set_Col(Output, 50);
               Put(Output, lel(i).key, 1);
               Set_Col(Output, 52);
               Put(Output, lel(i).ending);
               Set_Col(Output, 62);
               Put(Output, lel(i).age);
               Set_Col(Output, 64);
               Put(Output, lel(i).freq);
               New_Line(Output);
            end if;
         end loop;
      end if;

   end loop;

   New_Line;
   Put("LINE_INFLECTIONS finds "); Put(m); Put_Line(" inflections"); New_Line;

   for i in Character range ' '..' '  loop
      Integer_IO.Put(0); Put("    "); Put(i); Put("    "); Put(belf(0, i));
      Put("  ");   Put(bell(0, i));
      Put("    "); Put(bell(0, i) - belf(0, i) + 1); New_Line;
   end loop;
   New_Line;

   for i in Character range 'a'..'z'  loop
      for n in reverse 1..max_ending_size  loop
         if (lell(n, i) > 0)  and then (lelf(n, i) <= lell(n, i))  then
            Put(n); Put("    "); Put(i); Put("    "); Put(lelf(n, i));
            Put("  ");   Put(lell(n, i));
            Put("    "); Put(lell(n, i) - lelf(n, i) + 1); New_Line;
         end if;
      end loop;
   end loop;
   New_Line;

   for i in Character range 'a'..'z'  loop
      for n in reverse 1..max_ending_size  loop
         if (pell(n, i) > 0)  and then (pelf(n, i) <= pell(n, i))  then
            Put(n); Put("    "); Put(i); Put("    "); Put(pelf(n, i));
            Put("  ");   Put(pell(n, i));
            Put("    "); Put(pell(n, i) - pelf(n, i) + 1); New_Line;
         end if;
      end loop;
   end loop;
   New_Line;

   New_Line;
   Put(n5);  Put("    ");
   Put(n1);  Put("    ");
   Put(n2);  Put("    ");
   Put(n3);  Put("    ");
   Put(n4);  Put("    ");
   New_Line;

end makeinfl;
