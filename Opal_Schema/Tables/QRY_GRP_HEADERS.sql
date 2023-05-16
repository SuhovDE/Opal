--
-- QRY_GRP_HEADERS  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE OPAL_FRA.QRY_GRP_HEADERS
(
  QRY_ID         INTEGER                        NOT NULL,
  ATTR_ID        INTEGER                        NOT NULL,
  GRP_ID         INTEGER                        NOT NULL,
  GRP_LEV_ORDNO  INTEGER                        DEFAULT 1,
  VAL            VARCHAR2(30 CHAR)              NOT NULL,
  GRP_ID4VAL     INTEGER                        NOT NULL,
  D1             VARCHAR2(30 CHAR),
  D2             VARCHAR2(30 CHAR),
  D3             VARCHAR2(30 CHAR),
  D4             VARCHAR2(30 CHAR),
  L1             INTEGER,
  L2             INTEGER,
  L3             INTEGER,
  L4             INTEGER
)
ON COMMIT PRESERVE ROWS;

COMMENT ON COLUMN OPAL_FRA.QRY_GRP_HEADERS.GRP_ID4VAL IS 'Code of the group, correspondent to VAL';