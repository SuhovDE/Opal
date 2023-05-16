--
-- LANG_UTILS  (Package) 
--
--  Dependencies: 
--   LANGUAGES (Table)
--   OBJ_COL_IDS (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.lang_utils as
--!!!List of what is not done for germanization:
--4. error_txt
  lang_def constant languages.id%type := 1; --default language - English
  lang languages.id%type;
  all_value varchar2(30);
  dict_col_id constant OBJ_COL_IDS.col_id%type := 11;
 function get_lang return languages.id%type deterministic;
 procedure set_obj_lang;
 procedure set_child_attrs;
 procedure set_groups;
 procedure set_all;
end;
/