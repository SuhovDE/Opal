--
-- SHOW_ATTRS4DIMGRP  (View) 
--
--  Dependencies: 
--   AREAS (Table)
--   ATTRS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ATTRS4DIMGRP
(ID, CODE, DESCR, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, STORAGE_TYPE, AREA_CODE, AREA_DESCR, PARENT_AREA)
BEQUEATH DEFINER
AS 
select a.ID, a.abbr code, a.short descr, a.ATTR_TYPE, a.DIM_LEV_ID, a.AREA_ID,
  a.storage_type, r.abbr area_code, r.short area_descr, r.parent_id parent_area
 from attrs a, areas r
 where area_id<>0 and r.id=a.area_id
  and a.parent_id is null and a.dim_lev_id is not null;