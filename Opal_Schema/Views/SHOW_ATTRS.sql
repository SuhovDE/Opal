--
-- SHOW_ATTRS  (View) 
--
--  Dependencies: 
--   GET_CONST (Function)
--   SHOW_ALL_ATTRS (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_ATTRS
(ID, CODE, DESCR, ATTR_TYPE, DIM_LEV_ID, 
 AREA_ID, AREA_CODE, AREA_DESCR, PARENT_AREA, CUBE_ID, 
 SHOW, STORAGE_TYPE, PARENT_ID, FILTER_DISPLAY_NAME, FILTER_DISPLAY_TYPE, 
 ATTR_LVL, DISPLAY_FORMAT, DIM_GRP_ALLOWED)
BEQUEATH DEFINER
AS 
select a."ID",a."CODE",a."DESCR",a."ATTR_TYPE",a."DIM_LEV_ID",a."AREA_ID",a."AREA_CODE",a."AREA_DESCR",a."PARENT_AREA",a."CUBE_ID",a."SHOW",a."STORAGE_TYPE",a."PARENT_ID",a."FILTER_DISPLAY_NAME",a."FILTER_DISPLAY_TYPE",a."ATTR_LVL",a."DISPLAY_FORMAT",a."DIM_GRP_ALLOWED"
from show_all_attrs a
where parent_id is null;