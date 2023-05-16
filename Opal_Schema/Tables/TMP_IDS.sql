--
-- TMP_IDS  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE OPAL_FRA.TMP_IDS
(
  TASK    VARCHAR2(3 CHAR),
  ID      NUMBER(9),
  KEYSEQ  VARCHAR2(50 CHAR),
  DT      DATE
)
ON COMMIT DELETE ROWS;

COMMENT ON COLUMN OPAL_FRA.TMP_IDS.KEYSEQ IS 'Char keys';