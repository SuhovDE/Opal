ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS#PRIV
  CHECK (
 predefined not in ('P','N') and is_grp_priv is null or predefined in ('P','N') and nvl(is_grp_priv, 'x') in ('P','N'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS_GS
  CHECK (
grp_type='C' and nvl(grp_subtype, -1) between 0 and 3 or
grp_type='P' and nvl(grp_subtype, -1) between 0 and 1 or
grp_type not in ('C','P') and grp_subtype is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS_IL
  CHECK (nvl(is_leaf, 1) = 1)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS_P
  CHECK (nvl(predefined, '@') in ('Y','P','N','D'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS_T
  CHECK (nvl(grp_type, '@') in ('A','D','C','P'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT C_GROUPS_TA
  CHECK (type_id is not null or dom_id is not null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT P_GROUPS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT U_GROUPS_IG
  UNIQUE (ID, GRP_TYPE)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT U_GROUPS_IGL
  UNIQUE (ID, GRP_TYPE, IS_LEAF)
  ENABLE VALIDATE);