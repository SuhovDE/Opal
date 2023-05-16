--
-- TYPES_  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES_
(ID, DESCR, CD, PARENT_ID, TYPE_SIZE, 
 TYPE_PRECISION, TYPE_KIND, DIM_LEV_ID, TYPE_MASK, DOM_ID, 
 SCODE, DISPLAY_FORMAT, DIM_ID, ORDNO)
BEQUEATH DEFINER
AS 
select t."ID",t."DESCR",t."CD",t."PARENT_ID",t."TYPE_SIZE",t."TYPE_PRECISION",t."TYPE_KIND",t."DIM_LEV_ID",t."TYPE_MASK",t."DOM_ID",t."SCODE",t."DISPLAY_FORMAT", l.dim_id, l.ordno
 from attr_types t, dim_levels l
 where type_kind=get_const('dim_type') and t.dim_lev_id=l.id;