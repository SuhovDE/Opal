--
-- GRP_MEMBER  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."GRP_MEMBER" as object(id integer, code varchar2(30))
 alter type "OPAL_FRA"."GRP_MEMBER" modify attribute (CODE varchar2(30 char)) cascade
 alter type "OPAL_FRA"."GRP_MEMBER" add attribute date_from date cascade
 alter type "OPAL_FRA"."GRP_MEMBER" add attribute date_to date cascade
/