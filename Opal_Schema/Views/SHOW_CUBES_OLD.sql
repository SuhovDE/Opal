--
-- SHOW_CUBES_OLD  (View) 
--
--  Dependencies: 
--   CUBES (Table)
--   NAMES (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_CUBES_OLD
(ID, PARENT_ID, TAB, SCODE, SUF, 
 ABBR, SHORT, FULL, NAME, CHILD_NAME)
BEQUEATH DEFINER
AS 
select c."ID",c."PARENT_ID",c."TAB",c."SCODE",c."SUF",c."ABBR",c."SHORT",c."FULL", names(abbr, short) NAME, names(null) child_name from cubes c;