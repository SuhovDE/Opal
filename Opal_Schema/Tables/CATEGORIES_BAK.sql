--
-- CATEGORIES_BAK  (Table) 
--
--   Row Count: 0
CREATE TABLE OPAL_FRA.CATEGORIES_BAK
(
  ID       INTEGER,
  AREA_ID  INTEGER                              NOT NULL,
  NAME     VARCHAR2(40 CHAR)                    NOT NULL
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