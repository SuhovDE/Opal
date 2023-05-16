--
-- ATTRS4IN_D  (View) 
--
--  Dependencies: 
--   ATTRS_ (View)
--   GET_CONST (Function)
--   GROUP_DIM_TREE_TAB (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.ATTRS4IN_D
(OBJ_NAME, CODE, DESCR, GRP_ID, ATTR_ID, 
 LVL, PARENT_ID, DIM_ID, DIM_LEV_ID, RN, 
 GRP_TYPE)
BEQUEATH DEFINER
AS 
select
   'DIM_LEV' obj_name, g.code,
    case when g.parent_id is null or t.storage_type not in (get_const('datetype'), get_const('timetype')) then g.descr end descr,
    g.grp_id, t.id attr_id,
    t.ordno-g.ordno+1 lvl, g.parent_id, g.dim_id, g.dim_lev_id, g.rn, g.grp_type
 from group_dim_tree_tab g, attrs_ t
 where t.dim_id=g.dim_id and t.ordno>=g.ordno
 order by dim_id,rn;