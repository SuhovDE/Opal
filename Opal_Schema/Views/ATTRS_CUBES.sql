--
-- ATTRS_CUBES  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   DIM_LEVELS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.ATTRS_CUBES
(ID, ABBR, SHORT, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, EXPR_ID, STORAGE_TYPE, ATTR_SIZE, ATTR_PRECISION, 
 PARENT_ID, UNIT, SCODE, HIGHLIGHT, CATEGORY_ID, 
 DISPLAY_FORMAT, CUBE_ID, SHOW, RNG, ORDNO, 
 ATTR_SCODE, DIM_LEV_SCODE)
BEQUEATH DEFINER
AS 
select a.ID, a.abbr, a.short, a.ATTR_TYPE,a.DIM_LEV_ID,a.AREA_ID,a.EXPR_ID,a.STORAGE_TYPE,a.ATTR_SIZE,a.ATTR_PRECISION,a.PARENT_ID,a.UNIT,a.SCODE,
  coalesce(c.highlight, a.HIGHLIGHT) highlight, A.CATEGORY_ID, a.display_format,
  c.cube_id, c.show, c.rng, c.ordno, a.scode attr_scode, (select scode from dim_levels where id=a.dim_lev_id) dim_lev_scode
 from attrs a, attrs2cubes c
 where a.id=c.attr_id and c.show <> 'N' and c.excluded is null;