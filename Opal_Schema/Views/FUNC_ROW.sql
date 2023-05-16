--
-- FUNC_ROW  (View) 
--
--  Dependencies: 
--   DB_DIFF (Package)
--   FUNC_ROW_ (Table)
--   FUNC_ROW_DB (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.FUNC_ROW
(ID, FUNC_TYPE, PAR_NO, SUBST, PAR_TYPE, 
 RET_TYPE)
BEQUEATH DEFINER
AS 
select ID, FUNC_TYPE, PAR_NO,
  case DB_DIFF.GET_CURR_DB when 'ORACLE' then SUBST else (select SUBST from func_row_db where id=f.id and db_type=DB_DIFF.GET_CURR_DB) end SUBST,
  PAR_TYPE, RET_TYPE
 from func_row_ f;