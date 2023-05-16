--
-- TYPES4IN_D  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   GROUP_DIM_TREE_TAB (Table)
--   TYPES_ (View)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES4IN_D
(OBJ_NAME, CODE, DESCR, GRP_ID, TYPE_ID, 
 LVL, PARENT_ID, RN, GRP_TYPE, COMP_TYPE_ID, 
 DOM_ID, DIM_LEV_ID, DIM_ID, DATE_FROM, DATE_TO, 
 IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select
 'DIM_LEV' obj_name, g.code,
 case when g.parent_id is null or t.parent_id not in (-5, -6) then
  g.descr else '' end descr,
 g.grp_id, tc.type_id type_id,
-- t.ordno-g.ordno+1
 0 lvl,
 g.PARENT_ID, g.RN, g.GRP_TYPE
 ,tc.comp_type_id, g.dom_id, g.dim_lev_id, g.dim_id
 , g.DATE_FROM, g.date_to, cast(null as char(1))  is_grp_priv, cast(null as varchar2(30)) cr_user
from group_dim_tree_tab g, types_ t, types_comp tc
where --t.type_kind=tree_fnc.get_dim_type and
 t.dim_id=g.dim_id and
 t.ordno>=g.ordno
 and tc.comp_type_id=t.id
 and (tc.comp_type_id=tc.type_id or in_dim=0);