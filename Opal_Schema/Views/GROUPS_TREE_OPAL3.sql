--
-- GROUPS_TREE_OPAL3  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUPS_TREE_OPAL3
(ID, PARENT_ID, ORDNO_IN_ROOT, ALLREST, LVL, 
 RN, CODE, VCODE, DESCR, GRP_TYPE, 
 IS_LEAF, TYPE_ID, DIM_ID, PREDEFINED, DOM_ID, 
 FID, PRN, DIM_LEV_ID, DATE_FROM, DATE_TO, 
 IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select  --+index(g) index(t)
distinct  t.ID, t.PARENT_ID, case when t.id<>0 then t.ORDNO_IN_ROOT end ordno_in_root, ' ' ALLREST, 0 lvl,
  t.id rn,
  coalesce(gd.DIM_LEV_CODE, g.abbr) code,
  g.abbr vcode,
  g.short descr, g.grp_type, g.IS_LEAF, g.TYPE_ID, g.DIM_ID, g.predefined, g.dom_id,
  t.PARENT_ID fid,
  t.PARENT_ID prn, gd.dim_lev_id, t.date_from, t.date_to, g.is_grp_priv, g.cr_user
from grp_tree t  join groups g on t.id=g.id left outer join grp_d gd on t.id=gd.grp_id
where t.parent_id between 0 and 999999 and g.id<999999 or t.id=0;