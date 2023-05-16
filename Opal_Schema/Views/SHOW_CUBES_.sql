--
-- SHOW_CUBES_  (View) 
--
--  Dependencies: 
--   ATTRS2CUBES (Table)
--   CUBES (Table)
--   GRANTS4USER (Synonym)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_CUBES_
(ID, PARENT_ID, TAB, SCODE, ABBR, 
 SHORT)
BEQUEATH DEFINER
AS 
select ID, PARENT_ID, TAB, SCODE, abbr, short from cubes c
 where 1=grants4user.grant_cube(c.scode)
  and exists(select 1 from attrs2cubes where cube_id=c.id and excluded is null);