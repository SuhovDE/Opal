--
-- RS_CODES4DIMS_  (View) 
--
--  Dependencies: 
--   RS_CODES4DIMS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.RS_CODES4DIMS_
(DIM_LEV_ID, ATTR_TYPE_CODE, ATTR_TYPE_NAME, RS_NAME_SUF, DISPLAY_FORMAT, 
 COLNAME, NOSHOW)
BEQUEATH DEFINER
AS 
select DIM_LEV_ID, ATTR_TYPE_CODE, /*+nvl2(noshow, '---', ATTR_TYPE_NAME) */ATTR_TYPE_NAME, RS_NAME_SUF, DISPLAY_FORMAT, COLNAME, noshow
 from rs_codes4dims r where (noshow is null/* or attr_type_code=constants.get_code_code*/);