--
-- SHOW_GRP_DIMS4ATTRS  (View) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS4IN_D (View)
--   GET_CONST (Function)
--   TYPES4IN_G (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_GRP_DIMS4ATTRS
(OBJ_NAME, CODE, DESCR, GRP_ID, ATTR_ID, 
 LVL, UKEY, PARENT_KEY, DIM_ID, DIM_LEV_ID, 
 GRP_TYPE, RN, SHOW_IN_FULL, ORDNO_IN_ROOT)
BEQUEATH DEFINER
AS 
select OBJ_NAME, CODE, DESCR, GRP_ID, ATTR_ID, LVL,
  /*ukey*1000+attr_id */ukey,  /*parent_key*1000+attr_id*/ parent_key, dim_id, dim_lev_id, grp_type, rn,
  show_in_full, ordno_in_root
from (
 select OBJ_NAME, CODE, DESCR, GRP_ID, a.id attr_id, LVL, rn ukey, prn parent_key,
  cast(null as integer) dim_id, cast(null as integer) dim_lev_id, grp_type, rn, is_leaf, predefined, show_in_full, ordno_in_root
 from types4in_g, attrs a
 where type_id=a.attr_type and grp_type<>get_const('ph_group')
 union all
 select --+index(attrs4in_d.t.a)
   OBJ_NAME, CODE, DESCR, GRP_ID, ATTR_ID, LVL, grp_id ukey, parent_id parent_key, dim_id, dim_lev_id, grp_type, rn,
    1 is_leaf, 'Y' predefined, 0 show_in_full, cast(null as integer) ordno_in_root
  from attrs4in_d --where attr_id=current_state.get_current_attr
) j
where predefined<>get_const('grp_temporary');