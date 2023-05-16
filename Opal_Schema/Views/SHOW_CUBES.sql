--
-- SHOW_CUBES  (View) 
--
--  Dependencies: 
--   CUBES (Table)
--   GRANTS4USER (Synonym)
--   NAMES (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_CUBES
(ID, PARENT_ID, NAME, TAB, SCODE, 
 ABBR, SHORT, CHILD_NAME)
BEQUEATH DEFINER
AS 
select ID, PARENT_ID, names(abbr, short) NAME, TAB, SCODE, abbr, short, names(null) child_name from cubes c
 where 1=grants4user.grant_cube(c.scode);