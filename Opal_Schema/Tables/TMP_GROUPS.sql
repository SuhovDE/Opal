--
-- TMP_GROUPS  (Table) 
--
--   Row Count: 453
CREATE TABLE OPAL_FRA.TMP_GROUPS
(
  QRY_ID      INTEGER                           NOT NULL,
  GRP_ID      INTEGER                           NOT NULL,
  DIM_LEV_ID  INTEGER,
  VAL         VARCHAR2(30 CHAR)                 NOT NULL,
  DATE_FROM   DATE,
  DATE_TO     DATE
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