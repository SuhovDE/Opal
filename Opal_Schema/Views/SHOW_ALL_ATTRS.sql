--
-- SHOW_ALL_ATTRS  (View) 
--
--  Dependencies: 
--   AREAS (Table)
--   ATTRS (Table)
--   ATTRS_CUBES (View)
--   GET_CONST (Function)
--   GROUPS (Table)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ALL_ATTRS
(ID, CODE, DESCR, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, AREA_CODE, AREA_DESCR, PARENT_AREA, CUBE_ID, 
 SHOW, STORAGE_TYPE, PARENT_ID, FILTER_DISPLAY_NAME, FILTER_DISPLAY_TYPE, 
 ATTR_LVL, DISPLAY_FORMAT, DIM_GRP_ALLOWED, ATTR_SCODE, DIM_LEV_SCODE)
BEQUEATH DEFINER
AS 
SELECT a.ID, a.abbr code, a.short descr,
  a.ATTR_TYPE, a.DIM_LEV_ID, a.AREA_ID, r.abbr area_code, r.short area_descr,
  r.parent_id parent_area, a.cube_id, a.show, storage_type, a.parent_id,
  case when a.parent_id is null then a.abbr
   else concat((select aa.abbr from attrs aa where id=a.parent_id), concat(' ', a.abbr)) end FILTER_DISPLAY_NAME,
  storage_type FILTER_DISPLAY_TYPE,
  a.rng attr_lvl,
  a.display_format,
  case when a.dim_lev_id is not null then 1
  else (select coalesce(max(1), 0) from types_comp where type_id=a.attr_type) end dim_grp_allowed,
  attr_scode, dim_lev_scode
FROM (
 SELECT ID, abbr, short, ATTR_TYPE, DIM_LEV_ID, AREA_ID, CUBE_ID, parent_id, SHOW, storage_type, attr_size, attr_precision, unit, rng, display_format, attr_scode, dim_lev_scode
  FROM attrs_cubes a1
  WHERE show<>get_const('show_not')
 UNION ALL
 SELECT ID, abbr, short, ATTR_TYPE, DIM_LEV_ID, AREA_ID, CUBE_ID, parent_id, get_const('show_key'), storage_type,
   attr_size, attr_precision, unit, rng, display_format, attr_scode, dim_lev_scode
  FROM attrs_cubes a2
 WHERE show=get_const('show_val') AND EXISTS(SELECT 1 FROM GROUPS g WHERE id<>0 and --excluding root group
  a2.attr_type=g.type_id)
 ) a, AREAS r
WHERE /*area_id<>0 and */r.ID=a.area_id;