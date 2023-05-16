--
-- SHOW_ALL_ATTRS_X  (View) 
--
--  Dependencies: 
--   AREAS (Table)
--   ATTRS (Table)
--   ATTRS_CUBES (View)
--   CATEGORIES (Table)
--   DIM_LEVELS (Table)
--   GET_CONST (Function)
--   GROUPS (Table)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ALL_ATTRS_X
(ID, CODE, DESCR, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, AREA_CODE, AREA_DESCR, PARENT_AREA, CUBE_ID, 
 SHOW, STORAGE_TYPE, PARENT_ID, FILTER_DISPLAY_NAME, FILTER_DISPLAY_TYPE, 
 ATTR_LVL, DISPLAY_FORMAT, DIM_GRP_ALLOWED, SHOW_M, SHOW_D, 
 HIGHLIGHT, CATEGORY_ID, CATEGORY_NAME, ORDNO)
BEQUEATH DEFINER
AS 
select
 id, code, descr, attr_type, dim_lev_id, area_id, area_code, area_descr, parent_area, cube_id,
 cast(concat(case when show_d='Y' then get_const('show_key') end, case when show_m='Y' then get_const('show_val') end) as varchar(2)) show,
 storage_type, parent_id, FILTER_DISPLAY_NAME,
 FILTER_DISPLAY_TYPE, attr_lvl, display_format, dim_grp_allowed, show_m, show_d, highlight, category_id, category_name, ordno
from (
SELECT a.ID, a.abbr code, a.short descr,
  a.ATTR_TYPE, a.DIM_LEV_ID, a.AREA_ID, r.abbr area_code, r.short area_descr,
  r.parent_id parent_area, a.cube_id, a.show, a.storage_type, a.parent_id, a.highlight,
  case when a.parent_id is null then a.abbr else
   concat((select aa.abbr from attrs aa where id=a.parent_id), concat(' ', a.abbr)) end FILTER_DISPLAY_NAME,
  a.storage_type FILTER_DISPLAY_TYPE,
  a.rng attr_lvl,
  a.display_format,
  case when a.dim_lev_id is not null then 1 else (select coalesce(max(1), 0) from types_comp, dim_levels d where type_id=a.attr_type and comp_type_id=d.id) end dim_grp_allowed,
  case when a.show=get_const('show_val') then 'Y' else 'N' end show_m,
  case when a.show=get_const('show_key') then 'Y' else
   (SELECT coalesce(max('Y'), 'N') FROM GROUPS g WHERE id<>get_const('root_not_d') and --excluding root group
    a.attr_type=g.type_id) end show_d, a.category_id, c.name category_name, a.ordno
  FROM attrs_cubes a join AREAS r on r.ID=a.area_id left outer join categories c on a.category_id=c.id
  WHERE show<>get_const('show_not')
)
order by cube_id, area_id, category_name nulls first, ordno;