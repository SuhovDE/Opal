--
-- OPS  (Table) 
--
--   Row Count: 22
CREATE TABLE OPAL_FRA.OPS
(
  OP_SIGN  VARCHAR2(30 CHAR),
  OP_KIND  VARCHAR2(3 CHAR),
  SHOW     VARCHAR2(1 CHAR)                     DEFAULT 'Y'
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

COMMENT ON TABLE OPAL_FRA.OPS IS 'Admissible operations';

COMMENT ON COLUMN OPAL_FRA.OPS.OP_SIGN IS 'Operation sign';

COMMENT ON COLUMN OPAL_FRA.OPS.OP_KIND IS 'C - condition, L - condition leaf, E - expression';

COMMENT ON COLUMN OPAL_FRA.OPS.SHOW IS 'N - not shown to users';