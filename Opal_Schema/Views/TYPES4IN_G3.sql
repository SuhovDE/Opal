--
-- TYPES4IN_G3  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   GROUPS (Table)
--   GROUPS_TREE3 (View)
--   GRP_TREE (Table)
--   TYPES4GROUPS (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES4IN_G3
(OBJ_NAME, CODE, VCODE, DESCR, GRP_ID, 
 TYPE_ID, LVL, PARENT_ID, RN, GRP_TYPE, 
 PRN, IS_LEAF, PREDEFINED, FID, ORDNO_IN_ROOT, 
 DOM_ID, DIM_LEV_ID, DATE_FROM, DATE_TO, IS_GRP_PRIV, 
 CR_USER, SHOW_IN_FULL)
BEQUEATH DEFINER
AS 
select j."OBJ_NAME",j."CODE",j."VCODE",j."DESCR",j."GRP_ID",j."TYPE_ID",j."LVL",j."PARENT_ID",j."RN",j."GRP_TYPE",j."PRN",j."IS_LEAF",j."PREDEFINED",j."FID",j."ORDNO_IN_ROOT",j."DOM_ID",j."DIM_LEV_ID",j."DATE_FROM",j."DATE_TO",j."IS_GRP_PRIV",j."CR_USER",
   case when grp_type='C' then 0
   else nvl((select 0 from grp_tree t
        where rownum=1 and parent_id=j.fid  and exists(select 1 from groups where id=t.id and nvl(is_leaf,0)<>1)
         and not exists(select 1 from grp_tree where id=t.parent_id and nullif(parent_id, 0) is not null)
		 )
     , 1)
   end show_in_full
from(
select -- +index(t)
 'GROUP' obj_name, g.code, g.vcode, g.descr, g.id grp_id, tc.type_id,
  g.lvl, g.parent_id, g.rn, g.grp_type, g.prn, g.is_leaf, g.predefined, g.fid, g.ordno_in_root, g.dom_id, g.dim_lev_id
  , g.date_from, g.date_to, g.IS_GRP_PRIV, g.CR_USER
from groups_tree3 g, types4groups tc
where g.type_id=tc.grp_type_id
) j;