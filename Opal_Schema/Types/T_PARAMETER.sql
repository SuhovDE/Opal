--
-- T_PARAMETER  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."T_PARAMETER" as object (
   Name   varchar2(30),
   Value  varchar2(256)
)
 alter type "OPAL_FRA"."T_PARAMETER" modify attribute (NAME varchar2(30 char)) cascade
 alter type "OPAL_FRA"."T_PARAMETER" modify attribute (VALUE varchar2(256 char)) cascade
/