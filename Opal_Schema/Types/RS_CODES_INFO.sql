--
-- RS_CODES_INFO  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."RS_CODES_INFO" as object
(Attr_type_code  varchar2(30),
 Attr_type_name  varchar2(30),
 rs_name         varchar2(50),
 rs_display_name varchar2(50),
 display_format varchar2(30),
 colname varchar2(30))
 alter type "OPAL_FRA"."RS_CODES_INFO" add attribute (
 rs_ftype integer, rs_expr varchar2(4000)
) cascade including table data
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (ATTR_TYPE_CODE varchar2(30 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (ATTR_TYPE_NAME varchar2(30 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (COLNAME varchar2(30 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (DISPLAY_FORMAT varchar2(30 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (RS_DISPLAY_NAME varchar2(50 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (RS_EXPR varchar2(4000 char)) cascade
 alter type "OPAL_FRA"."RS_CODES_INFO" modify attribute (RS_NAME varchar2(50 char)) cascade
/