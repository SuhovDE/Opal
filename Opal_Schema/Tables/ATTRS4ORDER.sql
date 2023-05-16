--
-- ATTRS4ORDER  (Table) 
--
CREATE TABLE OPAL_FRA.ATTRS4ORDER
(
  ABBR     VARCHAR2(50 BYTE),
  ORDNO    NUMBER(3),
  CUBE_ID  INTEGER
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );