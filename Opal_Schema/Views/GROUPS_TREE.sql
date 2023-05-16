--
-- GROUPS_TREE  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   GROUPS_GL (Table)
--   GRP_D (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUPS_TREE
(ID, PARENT_ID, ORDNO_IN_ROOT, ALLREST, LVL, 
 RN, CODE, VCODE, DESCR, GRP_TYPE, 
 IS_LEAF, TYPE_ID, DIM_ID, PREDEFINED, DOM_ID, 
 FID, PRN, DIM_LEV_ID, DATE_FROM, DATE_TO, 
 IS_GRP_PRIV, CR_USER)
BEQUEATH DEFINER
AS 
select  --+index(g1) index(t)
distinct  t.ID, t.pid PARENT_ID, t.ORDNO_IN_ROOT, ' ' ALLREST, 0 lvl,
  gl_id rn,
  coalesce(gd.DIM_LEV_CODE, g1.abbr) code,
  g1.abbr vcode,
  g1.short descr, g1.grp_type, g1.IS_LEAF, g1.TYPE_ID, g1.DIM_ID, g1.predefined, g1.dom_id,
  t.fid,
  gl_pid prn, gd.dim_lev_id, t.date_from, t.date_to, g1.is_grp_priv, g1.cr_user
from groups_gl t left outer join grp_d gd on t.id=gd.grp_id join groups g1 on t.id=g1.id
where t.id<=999999;