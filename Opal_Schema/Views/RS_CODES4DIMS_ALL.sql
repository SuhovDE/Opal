--
-- RS_CODES4DIMS_ALL  (View) 
--
--  Dependencies: 
--   MULTIPLIER (Table)
--   RS_CODES4DIMS_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.RS_CODES4DIMS_ALL
(DIM_LEV_ID, ATTR_TYPE_CODE, ATTR_TYPE_NAME, RS_NAME_SUF, DISPLAY_FORMAT, 
 COLNAME)
BEQUEATH DEFINER
AS 
select DIM_LEV_ID, ATTR_TYPE_CODE, ATTR_TYPE_NAME, RS_NAME_SUF, display_format, colname from rs_codes4dims_
  union all
 select -1, 'FUN', '', '', '', '' from multiplier where n=1
  union all
 select -2, 'GROUP', '', 'C', '', 'PARENT_ID' from multiplier where n=1
  union all
 select -2, 'GROUP_NAME', '(Full)', 'N', '', 'SHORT' from multiplier where n=1
  union all
 select -3, 'GROUP', '(Filt)', 'C', '', '' from multiplier where n=1;