--
-- FUNC_GRP  (Table) 
--
--   Row Count: 5
CREATE TABLE OPAL_FRA.FUNC_GRP
(
  ID        VARCHAR2(30 CHAR),
  GRP_TYPE  INTEGER,
  NAME      VARCHAR2(50 CHAR),
  RES_TYPE  INTEGER                             DEFAULT 0                     NOT NULL
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

COMMENT ON TABLE OPAL_FRA.FUNC_GRP IS 'Allowed group functions of the system';

COMMENT ON COLUMN OPAL_FRA.FUNC_GRP.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.FUNC_GRP.GRP_TYPE IS 'Type of calculation of calculatable attributes in the lines of totals: 1 - the group function is applied to each member of the expression, 2 - to the calculated value';

COMMENT ON COLUMN OPAL_FRA.FUNC_GRP.RES_TYPE IS 'type of returning results, 0 - saves the type of argument';