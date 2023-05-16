ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT C_QUERY_TYPES_C
  CHECK (nvl(compare_allowed, '@') in ('M','O','N'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT C_QUERY_TYPES_G
  CHECK (nvl(groups_allowed, '@') in ('M','O','N'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT C_QUERY_TYPES_H
  CHECK (nvl(having_allowed, '@') in ('O','N','M'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT C_QUERY_TYPES_O
  CHECK (nvl(order_allowed, '@') in ('O','N','M'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT C_QUERY_TYPES_T
  CHECK (nvl(top_allowed, '@') in ('O','N','M'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QUERY_TYPES ADD (
  CONSTRAINT P_QUERY_TYPES_ID
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);