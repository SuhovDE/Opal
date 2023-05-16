--
-- MULTIPLIER  (Table) 
--
--   Row Count: 2
CREATE TABLE OPAL_FRA.MULTIPLIER
(
  N  NUMBER(2)                                  NOT NULL
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

COMMENT ON TABLE OPAL_FRA.MULTIPLIER IS 'For multiplying rows';