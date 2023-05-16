--
-- ATTRS_  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   DIM_LEVELS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.ATTRS_
(ID, ATTR_TYPE, DIM_LEV_ID, AREA_ID, EXPR_ID, 
 STORAGE_TYPE, ATTR_SIZE, ATTR_PRECISION, PARENT_ID, UNIT, 
 SCODE, HIGHLIGHT, CATEGORY_ID, SUF, ABBR, 
 SHORT, FULL, DIM_ID, ORDNO, DIM_ABBR, 
 DIM_SHORT)
BEQUEATH DEFINER
AS 
select a."ID",a."ATTR_TYPE",a."DIM_LEV_ID",a."AREA_ID",a."EXPR_ID",a."STORAGE_TYPE",a."ATTR_SIZE",a."ATTR_PRECISION",a."PARENT_ID",a."UNIT",a."SCODE",a."HIGHLIGHT",a."CATEGORY_ID",a."SUF",a."ABBR",a."SHORT",a."FULL", l.dim_id, l.ordno, l.abbr dim_abbr, l.short dim_short
 from attrs a, dim_levels l
 where a.dim_lev_id=l.id;