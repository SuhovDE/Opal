ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT C_GRP_TREE_IP
  CHECK (not (id>0 and parent_id<0))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT C_GRP_TREE_O
  CHECK (ordno_in_root is not null or parent_id<0)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT C_GRP_TREE_PO
  CHECK (nvl(ordno_in_root, -1)>=0)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT GRP_TREE_AR
  CHECK (allrest='R')
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT U_GRP_TREE_IP
  UNIQUE (ID, PARENT_ID, DATE_FROM)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT U_GRP_TREE_PO
  UNIQUE (PARENT_ID, ORDNO_IN_ROOT, DATE_FROM)
  DEFERRABLE INITIALLY DEFERRED
  ENABLE VALIDATE);