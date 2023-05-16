--
-- SHOW_COMP_TYPES  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--   SHOW_TYPES (View)
--   TYPES_COMP (Table)
--   TYPES_TREE (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_COMP_TYPES
(COMP_TYPE_ID, NAME, TYPE_ID, TYPE_SCODE, STORAGE_TYPE, 
 TYPE_MASK)
BEQUEATH DEFINER
AS 
select j."COMP_TYPE_ID",j."NAME",j."TYPE_ID",j."TYPE_SCODE", s.storage_type,
    s.type_mask
   from (
    select * from (
    select d.id comp_type_id, d.abbr name, a.id type_id, d.scode type_scode
     from dim_levels d, attr_types a, types_comp tc
 	 where coalesce(a.dim_lev_id, a.id)=tc.type_id and tc.comp_type_id=d.id
 	 order by d.dim_id, d.ordno desc
    )
  union
   select -- +index(t)
    t.type_id comp_type_id, t.descr name, t.grp_type_id type_id, t.scode type_scode
   from types_tree t
   where t.type_kind=get_const('basic_type') and t.type_id>0 and t.grp_type_id>0
  ) j, show_types s
  where j.comp_type_id=s.id;