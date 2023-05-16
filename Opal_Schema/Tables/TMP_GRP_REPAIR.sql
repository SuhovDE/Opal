--
-- TMP_GRP_REPAIR  (Table) 
--
--   Row Count: 0
CREATE TABLE OPAL_FRA.TMP_GRP_REPAIR
(
  OLD_ID  INTEGER                               NOT NULL,
  NEW_ID  INTEGER                               NOT NULL
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