--
-- RECS2CUBES  (Table) 
--
--   Row Count: 53
CREATE TABLE OPAL_FRA.RECS2CUBES
(
  CUBE_ID      INTEGER                          NOT NULL,
  ELEM_REC_ID  VARCHAR2(30 CHAR)                NOT NULL,
  PARENT_ID    VARCHAR2(30 CHAR),
  HOW_MUCH     VARCHAR2(1 CHAR),
  LVL_NAME     VARCHAR2(100 CHAR)               NOT NULL
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

COMMENT ON TABLE OPAL_FRA.RECS2CUBES IS 'Distribution of elementary records over Data cubes';

COMMENT ON COLUMN OPAL_FRA.RECS2CUBES.CUBE_ID IS 'Ref to Data cube';

COMMENT ON COLUMN OPAL_FRA.RECS2CUBES.ELEM_REC_ID IS 'Ref to elementary record';

COMMENT ON COLUMN OPAL_FRA.RECS2CUBES.PARENT_ID IS 'Parent record in Master-Detail relation';

COMMENT ON COLUMN OPAL_FRA.RECS2CUBES.HOW_MUCH IS 'Cardinal number of relation: 1-1:1, N - 1:N, C - 1:N, processed in a special way';