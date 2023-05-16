--
-- SHOW_PLACEHOLDERS  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   GROUPS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_PLACEHOLDERS
(TYPE_ID, CODE, ID)
BEQUEATH DEFINER
AS 
select type_id, g.short code, id
 from groups g
 where grp_type=get_const('ph_group') and predefined=get_const('grp_predefined')
  and is_leaf=1 and id>0 and g.grp_subtype=0;