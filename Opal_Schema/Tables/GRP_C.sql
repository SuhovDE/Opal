--
-- GRP_C  (Table) 
--
--  Dependencies: 
--   GROUPS (Table)
--
--   Row Count: 205
CREATE TABLE OPAL_FRA.GRP_C
(
  GRP_ID    INTEGER,
  IS_LEAF   INTEGER                             DEFAULT 1,
  GRP_TYPE  CHAR(1 BYTE)                        DEFAULT 'C',
  COND_ID   INTEGER
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

COMMENT ON TABLE OPAL_FRA.GRP_C IS 'Leaf properties of a Continuous group (type C)';

COMMENT ON COLUMN OPAL_FRA.GRP_C.GRP_ID IS 'Reference to GRP_TREE';

COMMENT ON COLUMN OPAL_FRA.GRP_C.IS_LEAF IS '1 always';

COMMENT ON COLUMN OPAL_FRA.GRP_C.GRP_TYPE IS 'C always';

COMMENT ON COLUMN OPAL_FRA.GRP_C.COND_ID IS 'Reference to condition, representing the continuous group interval, empty for ELSE conditions';