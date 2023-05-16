--
-- SHOW_TYPES  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--   DIM_LEVELS (Table)
--   DOMAINS (Table)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_TYPES
(ID, DESCR, PARENT_ID, TYPE_KIND, DIM_LEV_ID, 
 TYPE_MASK, STORAGE_TYPE, DOMAIN_NAME, DIM_GRP_ALLOWED, DOM_ID, 
 TYPE_SCODE, DOMAIN_SCODE)
BEQUEATH DEFINER
AS 
select  id, descr, parent_id, type_kind, dim_lev_id,
  aa.DISPLAY_FORMAT type_mask,
  storage_type, domain_name,
  case when aa.dim_lev_id is not null then 1 else (select coalesce(max(1), 0) from types_comp, dim_levels d where type_id=aa.id and comp_type_id=d.id) end dim_grp_allowed,
  dom_id , type_scode, domain_scode
from (
 with /*recursive*/ ftree(id, parent_id, lvl, root_id) as (
 select id, parent_id, 1 lvl, id root_id from attr_types
        where parent_id is not null
 union all
 select a.id, a.parent_id, ft.lvl+1 lvl, ft.root_id from attr_types a join ftree ft on a.id=ft.parent_id
 )
select a.id, a.descr, a.parent_id, a.type_kind, a.dim_lev_id, a.type_mask,
  case when a.dim_lev_id is not null then
   (select storage_type from dim_levels d where a.dim_lev_id=id)
  else (select id from ftree where root_id=a.id and parent_id is null) end storage_type,
  d.abbr domain_name, a.display_format,
  a.type_size, a.type_precision, a.dom_id, a.scode type_scode, d.scode domain_scode
 from attr_types a, domains d
 where a.id>0 and d.id=a.dom_id
) aa;