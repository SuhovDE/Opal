--
-- CONDS_BAK  (Table) 
--
--   Row Count: 16725
CREATE TABLE OPAL_FRA.CONDS_BAK
(
  ID         INTEGER,
  OP_SIGN    VARCHAR2(30 CHAR),
  PARENT_ID  INTEGER,
  IS_LEAF    INTEGER,
  GH         CHAR(1 BYTE),
  ORDNO      INTEGER,
  DESCR      VARCHAR2(30 CHAR)
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