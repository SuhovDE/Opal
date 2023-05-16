--
-- ATTRS2CUBES  (Table) 
--
--  Dependencies: 
--   CUBES (Table)
--   ELEM_RECS (Table)
--
--   Row Count: 2009
CREATE TABLE OPAL_FRA.ATTRS2CUBES
(
  ATTR_ID      INTEGER,
  CUBE_ID      INTEGER,
  SHOW         CHAR(1 BYTE)                     DEFAULT 'K',
  COL          VARCHAR2(30 CHAR),
  ELEM_REC_ID  VARCHAR2(30 CHAR),
  HIGHLIGHT    VARCHAR2(1000 CHAR),
  EXCLUDED     VARCHAR2(1 BYTE),
  SUBQRY       VARCHAR2(1000 CHAR),
  RNG          INTEGER,
  ORDNO        NUMBER(3)
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

COMMENT ON TABLE OPAL_FRA.ATTRS2CUBES IS 'Distribution of requisites to Data cubes';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.ATTR_ID IS 'Ref to attribute';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.CUBE_ID IS 'Ref to data cubes';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.SHOW IS 'K - show as key, V - show as values, N - don''t show (hidden attribute)';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.COL IS 'Only for test stage';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.ELEM_REC_ID IS 'Elementary record, to which attribute belongs (if to several)';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.HIGHLIGHT IS 'To store info about the attributes image on the screen (for a specific cube)';

COMMENT ON COLUMN OPAL_FRA.ATTRS2CUBES.EXCLUDED IS 'Not null - excluded from the table (for quick revoke)';