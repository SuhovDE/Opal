--
-- ATTRS2RECS  (Table) 
--
--   Row Count: 581
CREATE TABLE OPAL_FRA.ATTRS2RECS
(
  ATTR_ID      INTEGER,
  ELEM_REC_ID  VARCHAR2(30 CHAR),
  COL_NAME     VARCHAR2(30 CHAR)                NOT NULL
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

COMMENT ON TABLE OPAL_FRA.ATTRS2RECS IS 'Distribution of basic attributes in elementary data records';

COMMENT ON COLUMN OPAL_FRA.ATTRS2RECS.ATTR_ID IS 'Ref to attribute ID';

COMMENT ON COLUMN OPAL_FRA.ATTRS2RECS.ELEM_REC_ID IS 'Ref to elementary record ID';

COMMENT ON COLUMN OPAL_FRA.ATTRS2RECS.COL_NAME IS 'Column of the elementary record';