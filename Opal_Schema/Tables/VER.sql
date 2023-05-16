--
-- VER  (Table) 
--
--   Row Count: 106
CREATE TABLE OPAL_FRA.VER
(
  BUILD        INTEGER                          NOT NULL,
  PATCH        INTEGER                          NOT NULL,
  INSTALL_DT   DATE                             NOT NULL,
  META_SCHEMA  VARCHAR2(100 CHAR)               NOT NULL,
  FINISHED     CHAR(1 BYTE)                     DEFAULT 'N'
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

COMMENT ON TABLE OPAL_FRA.VER IS 'Versioning of the schema';

COMMENT ON COLUMN OPAL_FRA.VER.BUILD IS 'Build number';

COMMENT ON COLUMN OPAL_FRA.VER.PATCH IS 'Patch number inside the build';

COMMENT ON COLUMN OPAL_FRA.VER.INSTALL_DT IS 'Timestamp of installation';

COMMENT ON COLUMN OPAL_FRA.VER.META_SCHEMA IS 'Meta schema, for which the patch was installed';

COMMENT ON COLUMN OPAL_FRA.VER.FINISHED IS 'N - not finished (unsuccessful) installation, empty - successful';