--
-- SHOW_QRYS_SEL_FLAT  (View) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   GET_CONST (Function)
--   SHOW_QRYS_SEL_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_QRYS_SEL_FLAT
(QRY_ID, QRY_SEL_ID, LEVEL_ID, BASIC_ATTR_ID, ORDNO, 
 BASIC_ATTR_TYPE, BASIC_ATTR_NAME, LEVEL_NAME, ATTR_LVL, LEVEL_TYPE, 
 DIM_LEV_ID, GRP_TYPE, STORAGE_TYPE, ATTR_TYPE_CODE, ATTR_TYPE_NAME, 
 RS_NAME, RS_DISPLAY_NAME, DISPLAY_FORMAT, COLNAME, RS_FTYPE, 
 RS_EXPR)
BEQUEATH DEFINER
AS 
select s.QRY_ID, s.QRY_SEL_ID, s.LEVEL_ID, s.BASIC_ATTR_ID, s.ORDNO, s.BASIC_ATTR_TYPE, s.BASIC_ATTR_NAME, s.LEVEL_NAME, s.ATTR_LVL, s.LEVEL_TYPE, s.DIM_LEV_ID, s.GRP_TYPE, s.STORAGE_TYPE,
   t."ATTR_TYPE_CODE",t."ATTR_TYPE_NAME",t."RS_NAME",t."RS_DISPLAY_NAME",t."DISPLAY_FORMAT",t."COLNAME",t."RS_FTYPE",t."RS_EXPR"
  from SHOW_QRYS_SEL_ s, json_table(s.attr_info_type, '$[*]' columns(
 attr_type_code varchar(30) path '$.attr_type_code',
 attr_type_name varchar(30) path '$.attr_type_name',
 rs_name varchar(50) path '$.rs_name',
 rs_display_name varchar(50) path '$.rs_display_name',
 display_format varchar(30) path '$.display_format',
 colname varchar(30) path '$.colname',
 rs_ftype integer path '$.rs_ftype',
 rs_expr varchar(4000) path '$.rs_expr'
 )
) t;