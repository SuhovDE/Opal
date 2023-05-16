--
-- SHOW_DOMAINS  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIM_LEVELS (Table)
--   DOMAINS (Table)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_DOMAINS
(ID, DOMAIN_NAME, DESCR, DIM_GRP_ALLOWED, BASIC_TYPE_ID, 
 SCODE)
BEQUEATH DEFINER
AS 
select id, d.abbr domain_name, d.short descr,
   (select coalesce(max(1), 0) from dim_levels where dom_id=d.id) dim_grp_allowed,
   (select id from attr_types a where a.dom_id=d.id and coalesce(a.parent_id, -1)<0
      and not exists(select 1 from types_comp where
     comp_type_id=a.id and comp_type_id<>type_id)) basic_type_id, scode
  from domains d
  where d.id>0;