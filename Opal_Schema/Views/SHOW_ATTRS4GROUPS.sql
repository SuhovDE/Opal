--
-- SHOW_ATTRS4GROUPS  (View) 
--
--  Dependencies: 
--   AREAS (Table)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ATTRS4GROUPS
(ID, CODE, DESCR, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, AREA_CODE, AREA_DESCR, PARENT_AREA, STORAGE_TYPE, 
 FILTER_DISPLAY_NAME, FILTER_DISPLAY_TYPE)
BEQUEATH DEFINER
AS 
SELECT a.ID, a.abbr code, a.short descr,
  a.ATTR_TYPE, a.DIM_LEV_ID, a.AREA_ID, r.abbr area_code, r.short area_descr,
  r.parent_id parent_area, storage_type,
  case when a.parent_id is null then a.abbr
   else concat(concat((select aa.abbr from attrs aa where id=a.parent_id), ' '), a.abbr) end FILTER_DISPLAY_NAME,
  storage_type FILTER_DISPLAY_TYPE
FROM attrs a, AREAS r
WHERE r.ID=a.area_id and a.parent_id is null and
exists(select 1 from attrs2cubes where attr_id=a.id and excluded is null);