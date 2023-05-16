--
-- SHOW_DIMS4ATTRS  (View) 
--
--  Dependencies: 
--   ATTRS_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_DIMS4ATTRS
(BASIC_ATTR_ID, ATTR_TYPE, DIM_LEV_ID, STORAGE_TYPE, ATTR_SIZE, 
 ATTR_PRECISION, DIM_ID, ORDNO, ATTR_ID, DIM_CODE, 
 DIM_NAME, UKEY)
BEQUEATH DEFINER
AS 
select a.ID basic_attr_id, a1.ATTR_TYPE, a1.DIM_LEV_ID,
  a1.STORAGE_TYPE, a1.ATTR_SIZE, a1.ATTR_PRECISION,
  a.DIM_ID, a1.ordno, a1.id attr_id,
  a1.dim_abbr dim_code, a1.dim_short dim_name, 100000*a.id+a1.id ukey
 from attrs_ a, attrs_ a1
 where /*a.ordno>1 and */a.parent_id is null and a.dim_id=a1.dim_id and a1.ordno<=a.ordno
  and (a1.parent_id=a.id or a1.id=a.id);