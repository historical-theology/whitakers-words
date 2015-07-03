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

-- N.B: there is a set of duff assignments in the original source,
-- marked here with comments saying "apparently redundant?"; unsure
-- whether this is a bug

with word_support_package; use word_support_package;   --  for STEM_IO
with Strings_Package; use Strings_Package;
with latIn_File_names; use latIn_File_names;
with preface;
package body line_stuff is

   procedure load_dictionary(dict : in out dictionary;
                             dictionary_file_name : String)  is
      --  For loading a DICTIONARY list from a file
      --  Only used now for DICT.LOC

      dictionary_file : File_Type;
      blk_stem : constant stem_type := null_stem_type;
      sts : stems_type := null_stems_type;
      pt  : part_entry  := null_part_entry;
      tran : translation_record := null_translation_record;
      value : constant numeral_value_type := 0;
      mean : meaning_type := null_meaning_type;

      fc1, fc2, fc3, fc4 : Character;

      line, st_line : String(1..100) := (others => ' ');
      blank_line : constant String(1..100) := (others => ' ');
      l, ll, lll, last    : Integer := 0;
      number_of_dictionary_entries : Integer := 0;

      procedure Get_stem(s : in String;
                         stem : out stem_type; last : out Integer) is
         i  : Integer := 1;
         l  : Integer := s'First;
      begin
         stem := null_stem_type;
         --  Squeeze left
         while l <= s'Last and then s(l) = ' '  loop
            l := l + 1;
         end loop;
         --  Count until the first blank
         --  Return that String
         while l <= s'Last and then s(l) /= ' '  loop
            stem(i) := s(l);
            i := i + 1;
            l := l + 1;
         end loop;
         --  Return  last
         last := l;

      end Get_stem;

   begin

      Open(dictionary_file, In_File, dictionary_file_name);
      preface.Put("Dictionary loading");

      while not End_Of_File(dictionary_file)  loop
         --TEXT_IO.PUT_LINE("GETTING");
         st_line := blank_line;
         Get_Non_Comment_Line (dictionary_file, st_line, last);      --  STEMS
         --TEXT_IO.PUT_LINE("READ STEMS");

         line := blank_line;
         --TEXT_IO.PUT("1 ");
         Get_Non_Comment_Line (dictionary_file, line, l);           --  PART
         --TEXT_IO.PUT("2 ");
         part_entry_io.Get(line(1..l), pt, ll);
         --TEXT_IO.PUT("3 ");
         ----  KIND_ENTRY_IO.GET(LINE(LL+1..L), PT.POFS, KIND, LL);
         --TEXT_IO.PUT("4 ");
         translation_record_io.Get(line(ll+1..l), tran, lll);
         --TEXT_IO.PUT("5 ");
         --TEXT_IO.PUT_LINE("READ PART");

         --  Specialize for parts
         --  If ADV then look if the CO is something other than X
         --  If so (like POS) then only that stem is active, and the others => xxx
         --  Same for ADJ
         --  If the ADJ or ADV stems have different first letters then make them
         --  different dictionary entries  --  Do this in LOAD and in DICT.DIC
         --TEXT_IO.PUT_LINE("GETTING STEMS IN LOAD_DICTIONARY");

         sts := null_stems_type;
         ll := 1;
         --  Extract up to 4 stems
         for i in 1..number_of_stems(pt.pofs)  loop   --  EXTRACT STEMS
            Get_stem(st_line(ll..last), sts(i), ll);
         end loop;

         --for I in 1..NUMBER_OF_STEMS(PT.POFS)  loop
         --  TEXT_IO.PUT(STS(I));
         --end loop;
         --TEXT_IO.NEW_LINE;

         line := blank_line;
         Get_Non_Comment_Line (dictionary_file, line, l);         --  MEANING
         mean := Head(Trim (line(1..l)), max_meaning_size);
         --TEXT_IO.PUT_LINE("READ MEANING");

         --  Now take care of other first letters in a gross way
         fc1 := Lower_Case (sts(1)(1));
         fc2 := Lower_Case (sts(2)(1));
         fc3 := Lower_Case (sts(3)(1));
         fc4 := Lower_Case (sts(4)(1));
         if fc1 = 'v' then
            fc1 := 'u';
         end if;
         if fc1 = 'j' then
            fc1 := 'i';
         end if;
         if fc2 = 'v' then
            fc2 := 'u';
         end if;
         if fc2 = 'j' then
            fc2 := 'i';
         end if;
         if fc3 = 'v' then
            fc3 := 'u';
         end if;
         if fc3 = 'j' then
            fc3 := 'i';
         end if;
         if fc4 = 'v' then
            fc4 := 'u';
         end if;
         if fc4 = 'j' then
            fc4 := 'i';
         end if;
         if pt.pofs = n  then
            if sts(2)(1) /= sts(1)(1)  and then
               sts(2)(1) /= ' '        and then
               sts(2)(1..3) /= zzz_stem(1..3)
            then
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), zzz_stem, blk_stem, blk_stem),
                                        --PT, KIND, TRAN, MEAN), DICT(FC1));
                                        pt, tran, mean), dict(fc1));
               dict(fc2) :=
                 new dictionary_item'( ( (zzz_stem, sts(2), blk_stem, blk_stem),
                                         --PT, KIND, TRAN, MEAN), DICT(FC2) );
                                         pt, tran, mean), dict(fc2) );
            else
               --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
               dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                                 dict(fc1));
            end if;

         elsif pt.pofs = pron or pt.pofs = pack then
            if sts(2)(1) /= sts(1)(1)  and then
               sts(2)(1) /= ' '        and then
               sts(2)(1..3) /= zzz_stem(1..3)
            then
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), zzz_stem, blk_stem, blk_stem),
                                        --PT, KIND, TRAN, MEAN), DICT(FC1));
                                        pt, tran, mean), dict(fc1));
               dict(fc2) :=
                 new dictionary_item'( ( (zzz_stem, sts(2), blk_stem, blk_stem),
                                         --PT, KIND, TRAN, MEAN), DICT(FC2) );
                                         pt, tran, mean), dict(fc2) );
            else
               --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
               dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                                 dict(fc1));
            end if;

         elsif pt.pofs = adj  then
            if pt.adj.co   = x  then   --  X for all KINDs
               if (sts(2)(1) /= sts(1)(1) and then
                     sts(2)(1) /= ' '  and then
                     sts(2)(1..3) /= zzz_stem(1..3) ) or
                 (sts(3)(1) /= sts(1)(1) and then
                    sts(3)(1) /= ' '  and then
                    sts(3)(1..3) /= zzz_stem(1..3) ) or
                 (sts(4)(1) /= sts(1)(1) and then
                    sts(4)(1) /= ' '  and then
                    sts(4)(1..3) /= zzz_stem(1..3) )
               then
                  dict(fc1) :=
                    new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                           (adj, (pt.adj.decl, pos)),
                                           --KIND, TRAN, MEAN), DICT(FC1));
                                           tran, mean), dict(fc1));
                  dict(fc2) :=
                    new dictionary_item'( ( (zzz_stem, sts(2), blk_stem, blk_stem),
                                            (adj, (pt.adj.decl, pos)),
                                            --KIND, TRAN, MEAN), DICT(FC2) );
                                            tran, mean), dict(fc2) );
                  dict(fc3) :=
                    new dictionary_item'(( (zzz_stem, zzz_stem, sts(3), blk_stem),
                                           (adj, (pt.adj.decl, comp)),
                                           --KIND, TRAN, MEAN), DICT(FC3));
                                           tran, mean), dict(fc3));
                  dict(fc4) :=
                    new dictionary_item'(( (zzz_stem, zzz_stem, zzz_stem, sts(4)),
                                           (adj, (pt.adj.decl, super)),
                                           --KIND, TRAN, MEAN), DICT(FC4));
                                           tran, mean), dict(fc4));
               end if;
            elsif pt.adj.co   = pos   then
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                        --(ADJ, (PT.ADJ.DECL, POS)), KIND, TRAN, MEAN),
                                        (adj, (pt.adj.decl, pos)), tran, mean),
                                      dict(fc1));
               dict(fc2) :=
                 new dictionary_item'(((blk_stem,  sts(2), blk_stem, blk_stem),
                                       --(ADJ, (PT.ADJ.DECL, POS)), KIND, TRAN, MEAN),
                                       (adj, (pt.adj.decl, pos)), tran, mean),
                                      dict(fc2));
            elsif pt.adj.co   = comp  then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, blk_stem, sts(1), blk_stem),
                                        --(ADJ, (PT.ADJ.DECL, COMP)), KIND, TRAN, MEAN),
                                        (adj, (pt.adj.decl, comp)), tran, mean),
                                      dict(fc1));
            elsif pt.adj.co   = super then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, blk_stem, blk_stem, sts(1)),
                                        --(ADJ, (PT.ADJ.DECL, SUPER)), KIND, TRAN, MEAN),
                                        (adj, (pt.adj.decl, super)), tran, mean),
                                      dict(fc1));

            else
               --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
               dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                                 dict(fc1));
            end if;

         elsif pt.pofs = adv  then
            if pt.adv.co   = x  then   --  X for all KINDs
               if (sts(2)(1) /= sts(1)(1) and then
                     sts(2)(1) /= ' '  and then
                     sts(2)(1..3) /= zzz_stem(1..3) ) or
                 (sts(3)(1) /= sts(1)(1) and then
                    sts(3)(1) /= ' '  and then
                    sts(3)(1..3) /= zzz_stem(1..3) )
               then
                  dict(fc1) :=
                    new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                           --(ADV, (CO => POS)), KIND, TRAN, MEAN), DICT(FC1));
                                           (adv, (co => pos)), tran, mean), dict(fc1));
                  dict(fc2) :=
                    new dictionary_item'(( (sts(2), blk_stem, blk_stem, blk_stem),
                                           --(ADV, (CO => COMP)), KIND, TRAN, MEAN), DICT(FC2));
                                           (adv, (co => comp)), tran, mean), dict(fc2));
                  dict(fc3) :=
                    new dictionary_item'(( (sts(3), blk_stem, blk_stem, blk_stem),
                                           --(ADV, (CO => SUPER)), KIND, TRAN, MEAN), DICT(FC3));
                                           (adv, (co => super)), tran, mean), dict(fc3));
               end if;
            elsif pt.adv.co   = pos   then          --  just a specific KIND
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                        --(ADV, (CO => POS)), KIND, TRAN, MEAN),
                                        (adv, (co => pos)), tran, mean),
                                      dict(fc1));
            elsif pt.adv.co   = comp  then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, sts(1), blk_stem, blk_stem),
                                        --(ADV, (CO => COMP)), KIND, TRAN, MEAN),
                                        (adv, (co => comp)), tran, mean),
                                      dict(fc1));
            elsif pt.adv.co   = super then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, blk_stem, sts(1), blk_stem),
                                        --(ADV, (CO => SUPER)), KIND, TRAN, MEAN),
                                        (adv, (co => super)), tran, mean),
                                      dict(fc1));
            else
               --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
               dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                                 dict(fc1));
            end if;

         elsif pt.pofs = v  then
            if (sts(2)(1) /= sts(1)(1) and then
                  sts(2)(1) /= ' '  and then
                  sts(2)(1..3) /= zzz_stem(1..3) ) or
              (sts(3)(1) /= sts(1)(1) and then
                 sts(3)(1) /= ' '  and then
                 sts(3)(1..3) /= zzz_stem(1..3) ) or
              (sts(4)(1) /= sts(1)(1) and then
                 sts(4)(1) /= ' '  and then
                 sts(4)(1..3) /= zzz_stem(1..3) )
            then
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), zzz_stem, zzz_stem, zzz_stem),
                                        --PT, KIND, TRAN, MEAN), DICT(FC1) );
                                        pt, tran, mean), dict(fc1) );
               dict(fc2) :=
                 new dictionary_item'(( (zzz_stem, sts(2), zzz_stem, zzz_stem),
                                        --PT, KIND, TRAN, MEAN), DICT(FC2));
                                        pt, tran, mean), dict(fc2));
               dict(fc3) :=
                 new dictionary_item'(( (zzz_stem, zzz_stem, sts(3), zzz_stem),
                                        --PT, KIND, TRAN, MEAN), DICT(FC3));
                                        pt, tran, mean), dict(fc3));
               dict(fc4) :=
                 new dictionary_item'(( (zzz_stem, zzz_stem, zzz_stem, sts(4)),
                                        --PT, KIND, TRAN, MEAN), DICT(FC4));
                                        pt, tran, mean), dict(fc4));
            else
               --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
               dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                                 dict(fc1));
            end if;

         elsif pt.pofs = num  then
            if pt.num.sort = x  then   --  X for all KINDs
               if sts(1)(1) /= ' ' and then sts(1)(1..3) /= zzz_stem(1..3) then
                  dict(fc1) :=
                    new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                           --(NUM, (PT.NUM.DECL, CARD)), KIND, TRAN, MEAN),
                                           (num, (pt.num.decl, card, value)), tran, mean),
                                         dict(fc1));
               end if;
               if sts(2)(1) /= ' ' and then sts(2)(1..3) /= zzz_stem(1..3) then
                  dict(fc2) :=
                    new dictionary_item'(( (zzz_stem, sts(2), blk_stem, blk_stem),
                                           --(NUM, ((0, 0), ORD)), KIND, TRAN, MEAN),
                                           (num, ((0, 0), ord, value)), tran, mean),
                                         dict(fc2));
               end if;
               if sts(3)(1) /= ' ' and then sts(3)(1..3) /= zzz_stem(1..3) then
                  dict(fc3) :=
                    new dictionary_item'(( (zzz_stem, zzz_stem, sts(3), blk_stem),
                                           --(NUM, (PT.NUM.DECL, DIST)), KIND, TRAN, MEAN),
                                           (num, (pt.num.decl, dist, value)), tran, mean),
                                         dict(fc3));
               end if;
               if sts(4)(1) /= ' ' and then sts(4)(1..3) /= zzz_stem(1..3) then
                  dict(fc4) :=
                    new dictionary_item'(( (zzz_stem, zzz_stem, zzz_stem, sts(4)),
                                           --(NUM, (PT.NUM.DECL, ADVERB)), KIND, TRAN, MEAN),
                                           (num, (pt.num.decl, adverb, value)), tran, mean),
                                         dict(fc4));
               end if;
            elsif pt.num.sort = card  then
               dict(fc1) :=
                 new dictionary_item'(( (sts(1), blk_stem, blk_stem, blk_stem),
                                        --(NUM, (PT.NUM.DECL, CARD)), KIND, TRAN, MEAN),
                                        (num, (pt.num.decl, card, value)), tran, mean),
                                      dict(fc1));
            elsif pt.num.sort = ord   then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, sts(1), blk_stem, blk_stem),
                                        --(NUM, (PT.NUM.DECL, ORD)), KIND, TRAN, MEAN),
                                        (num, (pt.num.decl, ord, value)), tran, mean),
                                      dict(fc1));
            elsif pt.num.sort = dist  then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, blk_stem, sts(1), blk_stem),
                                        --(NUM, (PT.NUM.DECL, DIST)), KIND, TRAN, MEAN),
                                        (num, (pt.num.decl, dist, value)), tran, mean),
                                      dict(fc1));
            elsif pt.num.sort = adverb  then
               dict(fc1) :=
                 new dictionary_item'(( (blk_stem, blk_stem, blk_stem, sts(1)),
                                        --(NUM, (PT.NUM.DECL, ADVERB)), KIND, TRAN, MEAN),
                                        (num, (pt.num.decl, adverb, value)), tran, mean),
                                      dict(fc1));
            end if;

         else
            --DICT(FC1) := new DICTIONARY_ITEM'((STS, PT, KIND, TRAN, MEAN),
            dict(fc1) := new dictionary_item'((sts, pt, tran, mean),
                                              dict(fc1));

         end if;
         number_of_dictionary_entries := number_of_dictionary_entries + 1;
      end loop;
      Close(dictionary_file);
      preface.Set_Col(33); preface.Put("--  ");
      preface.Put(number_of_dictionary_entries, 6);
      preface.Put(" entries"); preface.Set_Col(55);
      preface.Put_Line("--  Loaded correctly");
   exception
      when others   =>
         preface.Put_Line("    LOAD_DICTIONARY exception        !!!!!!!!!!");
         preface.Put_Line(st_line(1..last));
         preface.Put_Line(line(1..l));
         Close(dictionary_file);
         preface.Set_Col(33); preface.Put("--  ");
         preface.Put(number_of_dictionary_entries, 6);
         preface.Put(" entries"); preface.Set_Col(55);
         preface.Put_Line("--  Loaded anyway   ");
   end load_dictionary;

   procedure load_stem_file(d_k : dictionary_kind)  is
      --  This is used to load a dictionary access file, like DIC.LOC
      --  It uses the single first letter index rather than the two letter
      --  This dictionary must be searched with a somewhat different procedure
      --  Not used when one loads from a regular STEMFILE (which uses two letters)
      --use LATIN_DEBUG;
      use stem_io;
      use dict_io;
      i : stem_io.Count := 1;
      --M_P_R : MEANING_TYPE;
      m : dict_io.Positive_Count := 1;
      dlc : dictionary := dict_loc;
      --DS : DICTIONARY_STEM;
      --ZZZ_STEM : constant STEM_TYPE := "zzz" & (4..MAX_STEM_SIZE => ' '); --####
   begin
      --PUT_LINE("LOAD_STEM_FILE for LOC");
      if Is_Open(stem_file(d_k))  then
         Delete(stem_file(d_k));
      end if;
      Create(stem_file(d_k), Inout_File, add_file_name_extension(stem_file_name,
                                                                 dictionary_kind'Image(d_k)));
      --PUT_LINE("LOAD_STEM_FILE for LOC - Created STEM_FILE");
      if Is_Open(dict_file(d_k))  then
         Delete(dict_file(d_k));
      end if;
      Create(dict_file(d_k), Inout_File, add_file_name_extension(dict_file_name,
                                                                 dictionary_kind'Image(d_k)));
      --PUT_LINE("LOAD_STEM_FILE for LOC - Created DICT_FILE");

      --PUT_LINE("L_D_F  Start  M = " & INTEGER'IMAGE(INTEGER(M)));

      for fc in Character range 'a'..'z'  loop
         --  LOAD_DICTIONARY should have assured that all v were in u
         --LATIN_DEBUG.PUT_LINE("L_D_F  Entering FC loop");
         ddlf(fc, 'a', d_k) := i;
         ddll(fc, 'a', d_k) := 0;
         while dlc(fc) /= null  loop
            --PUT_LINE("L_D_F  Setting Dictfile index M = " & INTEGER'IMAGE(INTEGER(M)));
            dict_io.Set_Index(dict_file(d_k), m);
            -- %%%%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%
            --PUT_LINE(DLC(FC).DE.TRAN.MEAN);
            -- M_P_R := DLC(FC).DE.TRAN.MEAN;
            --DICT_IO.WRITE(DICT_FILE(D_K), M_P_R);   --@@@@@@@@@@@@@@@@@@@@@
            dict_io.Write(dict_file(d_k), dlc(fc).de);
            for k in stem_key_type range 1..4  loop
               if dlc(fc).de.stems(k) /= null_stem_type  and
                 dlc(fc).de.stems(k) /= zzz_stem
               then
                  --LATIN_DEBUG.PUT(DLC(FC).DE.STEMS(K)); LATIN_DEBUG.PUT("  ..  ");
                  --LATIN_DEBUG.PUT(DLC(FC).DE.PART); LATIN_DEBUG.PUT("  ..  "); LATIN_DEBUG.PUT(K);
                  --LATIN_DEBUG.PUT("  ..  "); LATIN_DEBUG.PUT(INTEGER(M)); LATIN_DEBUG.NEW_LINE;
                  Write(stem_file(d_k),
                        (dlc(fc).de.stems(k), dlc(fc).de.part, k, m));
                  ddll(fc, 'a', d_k) := i;
                  --LATIN_DEBUG.PUT_LINE("L_D_F DDLL(FC, 'a', D_K) := I  = " & INTEGER'IMAGE(I));
                  i := i + 1;
               end if;
            end loop;
            dlc(fc) := dlc(fc).succ;
            m := m + 1;
            --PUT_LINE("L_D_F  22222  M = " & INTEGER'IMAGE(INTEGER(M)));
         end loop;
         --PUT_LINE("L_D_F  33333  M = " & INTEGER'IMAGE(INTEGER(M)));
      end loop;
      --PUT_LINE("L_D_F  44444  M = " & INTEGER'IMAGE(INTEGER(M)));
   end load_stem_file;

   package body tackon_line_io is
      use part_of_speech_type_io;
      use tackon_entry_io;
      spacer : Character := ' ';

      procedure Get(f : in File_Type; p : out tackon_line) is
      begin
         Get(f, p.pofs);
         Get(f, spacer);
         Get(f, p.tack);
         Get(f, spacer);
         Get(f, p.entr);
         Get(f, spacer);
         Get(f, p.mean);
      end Get;

      procedure Get(p : out tackon_line) is
      begin
         Get(p.pofs);
         Get(spacer);
         Get(p.tack);
         Get(spacer);
         Get(p.entr);
         Get(spacer);
         Get(p.mean);
      end Get;

      procedure Put(f : in File_Type; p : in tackon_line) is
      begin
         Put(f, p.pofs);
         Put(f, ' ');
         Put(f, p.tack);
         Put(f, ' ');
         Put(f, p.entr);
         Put(f, ' ');
         Put(f, p.mean);
      end Put;

      procedure Put(p : in tackon_line) is
      begin
         Put(p.pofs);
         Put(' ');
         Put(p.tack);
         Put(' ');
         Put(p.entr);
         Put(' ');
         Put(p.mean);
      end Put;

      procedure Get(s : in String; p : out tackon_line; last : out Integer) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Get(s(l+1..m), p.pofs, l);
         l := m + 1;
         m := l + max_stem_size;
         p.tack := s(l+1..m);
         l := m + 1;
         m := l + tackon_entry_io.Default_Width;
         Get(s(l+1..m), p.entr, l);
         l := m + 1;
         m := l + max_meaning_size;
         p.mean := s(l+1..m);
         last := m;
      end Get;

      procedure Put(s : out String; p : in tackon_line) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Put(s(l+1..m), p.pofs);
         l := m + 1;
         s(l) := ' ';
         m := l + max_stem_size;
         s(l+1..m) := p.tack;
         l := m + 1;
         s(l) := ' ';
         m := l + tackon_entry_io.Default_Width;
         Put(s(l+1..m), p.entr);
         l := m + 1;
         s(l) := ' ';
         m := l + max_meaning_size;
         s(l+1..m) := p.mean;
         s(m+1..s'Last) := (others => ' ');
      end Put;

   end tackon_line_io;

   package body prefix_line_io is
      use part_of_speech_type_io;
      use prefix_entry_io;
      spacer : Character := ' ';

      procedure Get(f : in File_Type; p : out prefix_line) is
      begin
         Get(f, p.pofs);
         Get(f, spacer);
         Get(f, p.fix);
         Get(f, spacer);
         Get(f, p.connect);
         Get(f, spacer);
         Get(f, p.entr);
         Get(f, spacer);
         Get(f, p.mean);
      end Get;

      procedure Get(p : out prefix_line) is
      begin
         Get(p.pofs);
         Get(spacer);
         Get(p.fix);
         Get(spacer);
         Get(p.connect);
         Get(spacer);
         Get(p.entr);
         Get(spacer);
         Get(p.mean);
      end Get;

      procedure Put(f : in File_Type; p : in prefix_line) is
      begin
         Put(f, p.pofs);
         Put(f, ' ');
         Put(f, p.fix);
         Put(f, ' ');
         Put(f, p.connect);
         Put(f, ' ');
         Put(f, p.entr);
         Put(f, ' ');
         Put(f, p.mean);
      end Put;

      procedure Put(p : in prefix_line) is
      begin
         Put(p.pofs);
         Put(' ');
         Put(p.fix);
         Put(' ');
         Put(p.connect);
         Put(' ');
         Put(p.entr);
         Put(' ');
         Put(p.mean);
      end Put;

      procedure Get(s : in String; p : out prefix_line; last : out Integer) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Get(s(l+1..s'Last), p.pofs, l);
         l := m;
         l := l + 1;
         m := l + max_stem_size;
         p.fix := s(l+1..m);
         l := m;
         l := l + 1;
         -- m := l + 1; -- apparently redundant?
         p.connect := s(l+1);
         l := l + 1;
         m := l + prefix_entry_io.Default_Width;
         Get(s(l+1..s'Last), p.entr, l);
         l := m + 1;
         m := l + max_meaning_size;
         p.mean := s(l+1..m);
         last := m;
      end Get;

      procedure Put(s : out String; p : in prefix_line) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Put(s(l+1..m), p.pofs);
         l := m + 1;
         s(l) :=  ' ';
         m := l + max_stem_size;
         s(l+1..m) := p.fix;
         l := m + 1;
         s(l) :=  ' ';
         -- m := l + 1; -- apparently redundant?
         s(l+1) := p.connect;
         m := l + prefix_entry_io.Default_Width;
         Put(s(l+1..m), p.entr);
         l := m + 1;
         s(l) :=  ' ';
         m := l + max_meaning_size;
         s(l+1..m) := p.mean;
         m := l + 1;
         s(m+1..s'Last) := (others => ' ');
      end Put;

   end prefix_line_io;

   package body suffix_line_io is
      use part_of_speech_type_io;
      use suffix_entry_io;
      spacer : Character := ' ';

      procedure Get(f : in File_Type; p : out suffix_line) is
      begin
         Get(f, p.pofs);
         Get(f, spacer);
         Get(f, p.fix);
         Get(f, spacer);
         Get(f, p.connect);
         Get(f, spacer);
         Get(f, p.entr);
         Get(f, spacer);
         Get(f, p.mean);
      end Get;

      procedure Get(p : out suffix_line) is
      begin
         Get(p.pofs);
         Get(spacer);
         Get(p.fix);
         Get(spacer);
         Get(p.connect);
         Get(spacer);
         Get(p.entr);
         Get(spacer);
         Get(p.mean);
      end Get;

      procedure Put(f : in File_Type; p : in suffix_line) is
      begin
         Put(f, p.pofs);
         Put(f, ' ');
         Put(f, p.fix);
         Put(f, ' ');
         Put(f, p.connect);
         Put(f, ' ');
         Put(f, p.entr);
         Put(f, ' ');
         Put(f, p.mean);
      end Put;

      procedure Put(p : in suffix_line) is
      begin
         Put(p.pofs);
         Put(' ');
         Put(p.fix);
         Put(' ');
         Put(p.connect);
         Put(' ');
         Put(p.entr);
         Put(' ');
         Put(p.mean);
      end Put;

      procedure Get(s : in String; p : out suffix_line; last : out Integer) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Get(s(l+1..s'Last), p.pofs, l);
         l := m;
         l := l + 1;
         m := l + max_stem_size;
         p.fix := s(l+1..m);
         l := m;
         l := l + 1;
         -- m := l + 1; -- apparently redundant?
         p.connect := s(l+1);
         l := l + 1;
         m := l + suffix_entry_io.Default_Width;
         Get(s(l+1..s'Last), p.entr, l);
         l := m + 1;
         m := l + max_meaning_size;
         p.mean := s(l+1..m);
         last := m;
      end Get;

      procedure Put(s : out String; p : in suffix_line) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + dictionary_kind_io.Default_Width;
         Put(s(l+1..m), p.pofs);
         l := m + 1;
         s(l) :=  ' ';
         m := l + max_stem_size;
         s(l+1..m) := p.fix;
         l := m + 1;
         s(l) :=  ' ';
         m := l + 1;
         s(l+1) := p.connect;
         l := m + 1;
         s(l) :=  ' ';
         m := l + suffix_entry_io.Default_Width;
         Put(s(l+1..m), p.entr);
         l := m + 1;
         s(l) :=  ' ';
         m := l + max_meaning_size;
         s(l+1..m) := p.mean;
         s(m+1..s'Last) := (others => ' ');
      end Put;

   end suffix_line_io;

   package body unique_entry_io is
      use quality_record_io;
      use kind_entry_io;
      use translation_record_io;
      spacer : Character;

      procedure Get(f : in File_Type; p : out unique_entry) is
         ue : unique_entry;
      begin
         Get(f, ue.stem);
         Get(f, spacer);
         Get(f, ue.qual);
         Get(f, spacer);
         Get(f, ue.qual.pofs, ue.kind);
         Get(f, spacer);
         Get(f, ue.tran);
         p := ue;
      end Get;

      procedure Get(p : out unique_entry) is
         ue : unique_entry;
      begin
         Get(p.stem);
         Get(spacer);
         Get(ue.qual);
         Get(spacer);
         Get(ue.qual.pofs, ue.kind);
         Get(spacer);
         Get(p.tran);
      end Get;

      procedure Put(f : in File_Type; p : in unique_entry) is
      begin
         Put(f, p.stem);
         Put(f, ' ');
         Put(f, p.qual);
         Put(f, ' ');
         Put(f, p.qual.pofs, p.kind);
         Put(f, ' ');
         Put(f, p.tran);
      end Put;

      procedure Put(p : in unique_entry) is
      begin
         Put(p.stem);
         Put(' ');
         Put(p.qual);
         Put(' ');
         Put(p.qual.pofs, p.kind);
         Put(' ');
         Put(p.tran);
      end Put;

      procedure Get(s : in String; p : out unique_entry; last : out Integer) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + max_stem_size;
         p.stem := s(l+1..m);
         l := l + 1;
         -- m := l + quality_record_io.Default_Width; -- apparently redundant?
         Get(s(l+1..s'Last), p.qual, l);
         l := l + 1;
         -- m := l + kind_entry_io.Default_Width; -- apparently redundant?
         Get(s(l+1..s'Last), p.qual.pofs, p.kind, l);
         l := l + 1;
         -- m := l + max_meaning_size; -- apparently redundant?
         Get(s(l+1..s'Last), p.tran, last);
      end Get;

      procedure Put(s : out String; p : in unique_entry) is
         l : Integer := s'First - 1;
         m : Integer := 0;
      begin
         m := l + max_stem_size;
         s(l+1..m) := p.stem;
         l := m + 1;
         s(l) :=  ' ';
         m := l + quality_record_io.Default_Width;
         Put(s(l+1..m), p.qual);
         l := m + 1;
         s(l) :=  ' ';
         m := l + kind_entry_io.Default_Width;
         Put(s(l+1..m), p.qual.pofs, p.kind);
         l := m + 1;
         s(l) :=  ' ';
         m := m + max_meaning_size;
         Put(s(l+1..m), p.tran);
         s(m+1..s'Last) := (others => ' ');
      end Put;

   end unique_entry_io;

   procedure load_uniques(unq : in out latin_uniques; file_name : in String) is
      use quality_record_io;
      use part_entry_io;
      use kind_entry_io;
      use translation_record_io;
      use dict_io;

      uniques_file : Text_IO.File_Type;
      blanks : constant String(1..100) := (others => ' ');
      line, stem_line : String(1..100) := (others => ' ');
      last, l : Integer := 0;
      stem : stem_type := null_stem_type;
      qual : quality_record;
      kind : kind_entry;
      --PART : PART_ENTRY := NULL_PART_ENTRY;
      tran : translation_record := null_translation_record;
      mnpc : mnpc_type := null_mnpc;
      mean : meaning_type := null_meaning_type;
      m : dict_io.Positive_Count := 1;

      number_of_uniques_entries : Integer := 0;

   begin
      --TEXT_IO.PUT_LINE("UNIQUES started");
      Text_IO.Open(uniques_file, Text_IO.In_File, file_name);
      preface.Set_Col(1);
      preface.Put("UNIQUES file loading");

      --    if DICT_IO.IS_OPEN(DICT_FILE(D_K))  then
      --      DICT_IO.DELETE(DICT_FILE(D_K));
      --    end if;
      --    DICT_IO.CREATE(DICT_FILE(D_K), DICT_IO.INOUT_FILE,  "");
      --         -- ADD_FILE_NAME_EXTENSION(DICT_FILE_NAME, DICTIONARY_KIND'IMAGE(D_K)));

      while not End_Of_File(uniques_file)  loop
         stem_line := blanks;
         Get_Line(uniques_file, stem_line, last);      --  STEM
         stem := Head(Trim (stem_line(1..last)), max_stem_size);

         line := blanks;
         Get_Line(uniques_file, line, last);    --  QUAL, KIND, TRAN
         Get(line(1..last), qual, l);
         Get(line(l+1..last), qual.pofs, kind, l);
         age_type_io.Get(line(l+1..last), tran.age, l);
         area_type_io.Get(line(l+1..last), tran.area, l);
         geo_type_io.Get(line(l+1..last), tran.geo, l);
         frequency_type_io.Get(line(l+1..last), tran.freq, l);
         source_type_io.Get(line(l+1..last), tran.source, l);

         line := blanks;
         Get_Line(uniques_file, line, l);         --  MEAN
         mean := Head(Trim (line(1..l)), max_meaning_size);
         --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         declare
            unique_de : dictionary_entry;
            part      : part_entry         := null_part_entry;
         begin
            case part.pofs is
               when n  =>
                  part := (n, (qual.n.decl, qual.n.gender, kind.n_kind));
               when pron =>
                  part := (pron, (qual.pron.decl, kind.pron_kind));
               when pack =>
                  part := (pack, (qual.pack.decl, kind.pack_kind));
               when adj =>
                  part := (adj, (qual.adj.decl, qual.adj.co));
               when num =>
                  part := (num, (qual.num.decl, qual.num.sort, kind.num_value));
               when adv =>
                  part := (adv, (co => qual.adv.co));
               when v =>
                  part := (v, (qual.v.con, kind.v_kind));
               when others  =>
                  part := null_part_entry;
            end case;

            unique_de.stems := (stem,
                                null_stem_type, null_stem_type, null_stem_type);
            unique_de.part  :=  part;
            --UNIQUE_DE.KIND  :=  KIND;
            unique_de.tran  :=  tran;
            unique_de.mean  :=  mean;

            --        DICT_IO.SET_INDEX(DICT_FILE(D_K), M);
            --        DICT_IO.WRITE(DICT_FILE(D_K), UNIQUE_DE);

            uniques_de(m) := unique_de;
         end;
         --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

         mnpc := m;

         if Lower_Case (stem(1)) = 'v' then
            unq('u') :=
              new unique_item'(stem, qual, kind, mnpc, unq(Lower_Case ('u')));
         elsif Lower_Case (stem(1)) = 'j' then
            unq('i') :=
              new unique_item'(stem, qual, kind, mnpc, unq(Lower_Case ('i')));
         else
            unq(Lower_Case (stem(1))) :=
              new unique_item'(stem, qual, kind, mnpc, unq(Lower_Case (stem(1))));
         end if;

         m := m + 1;
         number_of_uniques_entries := Integer(m) - 1;

      end loop;
      Close(uniques_file);
      preface.Set_Col(33);
      preface.Put("--  "); preface.Put(number_of_uniques_entries, 6);
      preface.Put(" entries");
      preface.Set_Col(55); preface.Put_Line("--  Loaded correctly");
   exception
      when Text_IO.Name_Error  =>
         preface.Put_Line("There is no UNIQUES file");
      when others   =>
         preface.New_Line;
         preface.Put_Line("LOAD_UNIQUES exception        !!!!!!!!!!!!!!!!!!!!!");
         preface.Put_Line(stem_line(1..last));
         preface.Put_Line(line(1..l));
         Close(uniques_file);
         preface.Set_Col(33);
         preface.Put("--  "); preface.Put(number_of_uniques_entries, 6);
         preface.Put(" entries");
         preface.Set_Col(55); preface.Put_Line("--  Loaded before error");
         --raise;
   end load_uniques;

begin

   --  PARSE_LINE_IO.DEFAULT_WIDTH :=
   --                                   MAX_STEM_SIZE + 1 +
   --                                   INFLECTION_RECORD_IO.DEFAULT_WIDTH + 1 +
   --                                   DICTIONARY_KIND_IO.DEFAULT_WIDTH + 1 +
   --                                   MAX_MEANING_SIZE;

   prefix_line_io.Default_Width := part_of_speech_type_io.Default_Width + 1 +
     max_stem_size + 1 +
     1 + 1 +
     prefix_entry_io.Default_Width + 1 +
     max_meaning_size;
   suffix_line_io.Default_Width := part_of_speech_type_io.Default_Width + 1 +
     max_stem_size + 1 +
     1 + 1 +
     suffix_entry_io.Default_Width + 1 +
     max_meaning_size;
   tackon_line_io.Default_Width := part_of_speech_type_io.Default_Width + 1 +
     max_stem_size + 1 +
     tackon_entry_io.Default_Width + 1 +
     max_meaning_size;

   unique_entry_io.Default_Width := max_stem_size + 1 +
     inflection_record_io.Default_Width + 1 +
     translation_record_io.Default_Width;

end line_stuff;
