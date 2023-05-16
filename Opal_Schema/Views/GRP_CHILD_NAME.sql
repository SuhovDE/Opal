--
-- GRP_CHILD_NAME  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   GRP_TREE (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GRP_CHILD_NAME
(PARENT_ID, ORD, ID, ABBR, SHORT, 
 TYPE_ID, DIM_ID, DOM_ID)
BEQUEATH DEFINER
AS 
select t.parent_id, t.ordno_in_root ord, t.id, g.abbr abbr, g.short short, g.type_id, g.dim_id, g.dom_id
  from grp_tree t, groups g
  where t.id=g.id;