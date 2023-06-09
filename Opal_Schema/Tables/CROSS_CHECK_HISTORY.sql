--
-- CROSS_CHECK_HISTORY  (Table) 
--
--   Row Count: 25
CREATE TABLE OPAL_FRA.CROSS_CHECK_HISTORY
(
  ID         INTEGER GENERATED BY DEFAULT AS IDENTITY ( START WITH 38 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP NOSCALE) NOT NULL,
  DATE_TIME  DATE,
  PARAMETRS  VARCHAR2(50 CHAR),
  USER_NAME  VARCHAR2(50 CHAR)                  DEFAULT null,
  RESULT     VARCHAR2(50 CHAR)                  DEFAULT null
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