--
-- FOLDERS_BAK  (Table) 
--
--   Row Count: 154
CREATE TABLE OPAL_FRA.FOLDERS_BAK
(
  ID     INTEGER,
  PID    INTEGER,
  ABBR   VARCHAR2(30 CHAR)                      NOT NULL,
  DESCR  VARCHAR2(256 CHAR),
  SCODE  VARCHAR2(30 CHAR)
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