--
-- TMP_ATTRS2CUBES  (Table) 
--
--   Row Count: 88
CREATE TABLE OPAL_FRA.TMP_ATTRS2CUBES
(
  SCODE        VARCHAR2(30 CHAR),
  CUBE_ID      INTEGER,
  SHOW         CHAR(1 BYTE),
  COL          VARCHAR2(30 CHAR),
  ELEM_REC_ID  VARCHAR2(30 CHAR)
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