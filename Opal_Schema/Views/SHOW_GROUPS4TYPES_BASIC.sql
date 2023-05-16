--
-- SHOW_GROUPS4TYPES_BASIC  (View) 
--
--  Dependencies: 
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--   TYPES4IN_D_OPAL3 (View)
--   TYPES4IN_G_OPAL3 (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_GROUPS4TYPES_BASIC
(OBJ_NAME, CODE, VCODE, DESCR, GRP_ID, 
 TYPE_ID, PARENT_ID, GRP_TYPE, UKEY, PARENT_KEY, 
 IS_LEAF, PREDEFINED, SHOW_IN_FULL, ORDNO_IN_ROOT, DOM_ID, 
 DIM_LEV_ID, DIM_LEV_SCODE, FLAGS, IS_REAL_GROUP, LVL, 
 RN, DATE_FROM, DATE_TO, IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select j.OBJ_NAME,j.CODE,j.VCODE,coalesce(j.descr, j.code) DESCR,j.GRP_ID,j.TYPE_ID,j.PARENT_ID,
       j.GRP_TYPE,j.UKEY,j.PARENT_KEY,j.IS_LEAF,j.PREDEFINED,j.SHOW_IN_FULL,
       j.ORDNO_IN_ROOT,j.DOM_ID,j.DIM_LEV_ID, (select scode from dim_levels where id=j.dim_lev_id) dim_lev_scode,
  cast(null as integer) flags, --obsolete column
  case when grp_type is null then 3 --separator
       when grp_id<0 then 0 --member of dim group
	   when grp_id=0 then 2 --root
	   when grp_type=get_const('dim_group') then 1 --dim group
	   when is_leaf=1 then 5 --interval
	   else 4 --interval group
  end is_real_group, cast(null as integer) lvl, cast(null as integer) rn, date_from, date_to, is_grp_priv, cr_user
from (
select  --distinct --distinct is added because of hierarchy compatibility, when a type is compatible for many members
  OBJ_NAME,
  case when grp_id between -99 and  -1 then (select d.scode from dims d where d.id=abs(grp_id))
  else code end CODE,
  vcode,DESCR,GRP_ID,TYPE_ID, PARENT_ID, GRP_TYPE,
  rn ukey, prn parent_key, is_leaf, predefined, show_in_full, g.ordno_in_root, g.dom_id, g.dim_lev_id
  , g.date_from, g.date_to, g.IS_GRP_PRIV, g.CR_USER
  from TYPES4IN_G_OPAL3 g
 union all
select /*+index(TYPES4IN_d.t.t p_attr_types)*/
    distinct --distinct is added because of hierarchy compatibility, when a type is compatible for many members
   OBJ_NAME,
    case when code is null and grp_id between -99 and  -1 then (select scode from dims where id=dim_id)
    else code end CODE,
    code vcode, DESCR, GRP_ID,TYPE_ID,PARENT_ID, GRP_TYPE,
   grp_id ukey, parent_id parent_key, 1 is_leaf, 'Y' predefined, 0 show_in_full, cast(null as integer) ordno_in_root, dom_id, dim_lev_id
   , date_from, date_to, IS_GRP_PRIV, CR_USER
from TYPES4IN_D_OPAL3
) j;