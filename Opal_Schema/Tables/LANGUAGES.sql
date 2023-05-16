--
-- LANGUAGES  (Table) 
--
--   Row Count: 2
CREATE TABLE OPAL_FRA.LANGUAGES
(
  ID        INTEGER,
  NAME      VARCHAR2(30 CHAR)                   NOT NULL,
  ENCODING  VARCHAR2(30 CHAR)
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