--
-- OPS4TYPES  (Table) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--
--   Row Count: 42
CREATE TABLE OPAL_FRA.OPS4TYPES
(
  TYPE_ID    INTEGER,
  OP_SIGN    VARCHAR2(30 CHAR),
  OP_KIND    VARCHAR2(3 CHAR)                   DEFAULT ('L'),
  TYPE_KIND  CHAR(1 BYTE)                       DEFAULT ('B'), 
  CONSTRAINT PK_OPS4TYPES
  PRIMARY KEY
  (TYPE_ID, OP_SIGN)
  ENABLE VALIDATE
)
ORGANIZATION INDEX
PCTTHRESHOLD 50
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

COMMENT ON COLUMN OPAL_FRA.OPS4TYPES.OP_KIND IS 'Always L, only for references on OPS';

COMMENT ON COLUMN OPAL_FRA.OPS4TYPES.TYPE_KIND IS 'Always B, only for references on ATTR_TYPES';