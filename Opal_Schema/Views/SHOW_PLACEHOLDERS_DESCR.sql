--
-- SHOW_PLACEHOLDERS_DESCR  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DB_DIFF (Package)
--   FUNC_ROW (View)
--   GROUPS (Table)
--   GRP_P (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_PLACEHOLDERS_DESCR
(GRP_ID, PH_NAME, TYPE_ID, PH_TYPE, FUNCTION)
BEQUEATH DEFINER
AS 
select grp_id, g.short PH_name, type_id, t.descr PH_type,
  replace(f.subst, ':%R1', p.param) function
 from grp_p p, attr_types t, groups g, func_row f
 where
  p.grp_id=g.id and t.id=g.TYPE_ID  and f.id=p.FUNC_ID;