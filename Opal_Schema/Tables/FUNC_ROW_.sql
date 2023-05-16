--
-- FUNC_ROW_  (Table) 
--
--   Row Count: 31
CREATE TABLE OPAL_FRA.FUNC_ROW_
(
  ID         VARCHAR2(30 CHAR),
  FUNC_TYPE  CHAR(1 BYTE),
  PAR_NO     INTEGER                            DEFAULT 1                     NOT NULL,
  SUBST      VARCHAR2(255 CHAR),
  PAR_TYPE   INTEGER,
  RET_TYPE   INTEGER
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

COMMENT ON TABLE OPAL_FRA.FUNC_ROW_ IS 'Allowed row functions of the system';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.FUNC_TYPE IS 'O - Oracle, U - user-defined, S - Substitution';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.PAR_NO IS 'Number of parameters, allowed now only 1';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.SUBST IS 'Substitution string for the function of FUNC_TYPE U';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.PAR_TYPE IS 'Parameter type (only 1 parameter is allowed!)  ';

COMMENT ON COLUMN OPAL_FRA.FUNC_ROW_.RET_TYPE IS 'Return type of the function';