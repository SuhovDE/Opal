--
-- GROUPS_TREE3  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUPS_TREE3
(ID, PARENT_ID, ORDNO_IN_ROOT, ALLREST, LVL, 
 RN, CODE, VCODE, DESCR, GRP_TYPE, 
 IS_LEAF, TYPE_ID, DIM_ID, PREDEFINED, DOM_ID, 
 FID, PRN, DIM_LEV_ID, DATE_FROM, DATE_TO, 
 IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select  --+index(g1) index(t)
distinct  t.ID, t.PARENT_ID, t.ORDNO_IN_ROOT, ' ' ALLREST, 0 lvl,
  t.id rn,
  nvl(gd.DIM_LEV_CODE, g1.abbr) code,
  g1.abbr vcode,
  g1.short descr, g1.grp_type, g1.IS_LEAF, g1.TYPE_ID, g1.DIM_ID, g1.predefined, g1.dom_id,
  nvl(nullif(t.parent_id, 0), t.id) fid,
  t.parent_id prn, gd.dim_lev_id, t.date_from, t.date_to, g1.is_grp_priv, g1.cr_user
from grp_tree t, grp_d gd, groups g1
where t.id=gd.grp_id(+) and t.id=g1.id and t.id<=999999 and (t.parent_id>=0 or t.parent_id is null and t.id>=0);