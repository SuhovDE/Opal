--
-- T_RC_NAME  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."T_RC_NAME" as object (
 No integer,
 Name varchar2(30)
)
 alter type "OPAL_FRA"."T_RC_NAME" modify attribute (NAME varchar2(30 char)) cascade
/