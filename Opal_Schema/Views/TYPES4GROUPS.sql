--
-- TYPES4GROUPS  (View) 
--
--  Dependencies: 
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--   TYPES_ (View)
--   TYPES_COMP (Table)
--   TYPES_TREE (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES4GROUPS
(TYPE_ID, GRP_TYPE_ID)
BEQUEATH DEFINER
AS 
select type_id, grp_type_id
 from types_tree
union
select  tc.type_id,  d.id grp_type_id
from types_ t, dim_levels d, types_comp tc
where
 t.ordno>=d.ordno
 and tc.comp_type_id=t.id
 and t.dim_id=d.dim_id
 and (tc.comp_type_id=tc.type_id or in_dim=0);