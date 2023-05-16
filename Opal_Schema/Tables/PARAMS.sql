--
-- PARAMS  (Table) 
--
--   Row Count: 33
CREATE TABLE OPAL_FRA.PARAMS
(
  TASKID    VARCHAR2(10 CHAR)                   DEFAULT 'GEN',
  PARID     VARCHAR2(30 CHAR)                   NOT NULL,
  PARTYPE   CHAR(1 BYTE),
  PARVALUE  VARCHAR2(1024 CHAR),
  PARNAME   VARCHAR2(100 CHAR),
  PARINTID  VARCHAR2(30 CHAR),
  STARTDT   DATE                                DEFAULT (to_date('01.01.1980', 'dd.mm.yyyy')),
  ENDDT     DATE                                DEFAULT (to_date('01.01.2180', 'dd.mm.yyyy')),
  DTMASK    VARCHAR2(20 CHAR)
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

COMMENT ON TABLE OPAL_FRA.PARAMS IS 'Parameters of the tasks';

COMMENT ON COLUMN OPAL_FRA.PARAMS.TASKID IS 'Task identifier';

COMMENT ON COLUMN OPAL_FRA.PARAMS.PARID IS 'Parameter identifier';

COMMENT ON COLUMN OPAL_FRA.PARAMS.PARTYPE IS 'Parameter type, C- character, D - date yyyy.mm.dd,N-numeric, L-comma-separated list';

COMMENT ON COLUMN OPAL_FRA.PARAMS.PARVALUE IS 'Parameter value';

COMMENT ON COLUMN OPAL_FRA.PARAMS.PARNAME IS 'Parameter name';