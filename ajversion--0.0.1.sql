-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ajversion" to load this file. \quit

CREATE TYPE ajversion;

CREATE OR REPLACE FUNCTION ajversion_in(cstring)
    RETURNS ajversion
    AS 'MODULE_PATHNAME'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION ajversion_out(ajversion)
    RETURNS cstring
    AS 'MODULE_PATHNAME'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION ajversion_recv(internal)
RETURNS ajversion LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE AS 'int4recv';

CREATE FUNCTION ajversion_send(ajversion)
RETURNS bytea LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE AS 'int4send';

CREATE TYPE ajversion (
    INPUT    = ajversion_in,
    OUTPUT   = ajversion_out,
    RECEIVE  = ajversion_recv,
    SEND     = ajversion_send,
    LIKE     = integer,
    CATEGORY = 'S'
);
COMMENT ON TYPE ajversion IS 'semantig version stored in 4 bytes';

CREATE FUNCTION ajversion(integer)
RETURNS ajversion
AS 'MODULE_PATHNAME', 'ajversion_from_int'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajversion(numeric)
RETURNS ajversion AS $$ SELECT $1::text::ajversion $$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION ajversion(real)
RETURNS ajversion AS $$ SELECT $1::text::ajversion $$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION ajversion(double precision)
RETURNS ajversion AS $$ SELECT $1::text::ajversion $$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (integer AS ajversion) WITH FUNCTION ajversion(integer);
CREATE CAST (numeric AS ajversion) WITH FUNCTION ajversion(numeric);
CREATE CAST (real AS ajversion) WITH FUNCTION ajversion(real);
CREATE CAST (double precision AS ajversion) WITH FUNCTION ajversion(double precision);

CREATE FUNCTION ajversion_eq(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_ne(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_lt(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_le(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_gt(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_ge(ajversion, ajversion)
RETURNS boolean LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION ajversion_cmp(ajversion, ajversion)
RETURNS integer LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME';

CREATE FUNCTION hash_ajversion(ajversion)
RETURNS integer LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE  AS 'hashint4';

CREATE FUNCTION major(ajversion) RETURNS integer
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME', 'ajversion_major';

CREATE FUNCTION minor(ajversion) RETURNS integer
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME', 'ajversion_minor';

CREATE FUNCTION patch(ajversion) RETURNS integer
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE  AS 'MODULE_PATHNAME', 'ajversion_patch';


CREATE OPERATOR = (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_eq,
    COMMUTATOR = '=',
    NEGATOR = '<>',
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);
COMMENT ON OPERATOR =(ajversion, ajversion) IS 'equals?';

CREATE OPERATOR <> (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_ne,
    COMMUTATOR = '<>',
    NEGATOR = '=',
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);
COMMENT ON OPERATOR <>(ajversion, ajversion) IS 'not equals?';

CREATE OPERATOR < (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_lt,
    COMMUTATOR = > ,
    NEGATOR = >= ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <(ajversion, ajversion) IS 'less-than';

CREATE OPERATOR <= (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_le,
    COMMUTATOR = >= ,
    NEGATOR = > ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <=(ajversion, ajversion) IS 'less-than-or-equal';

CREATE OPERATOR > (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_gt,
    COMMUTATOR = < ,
    NEGATOR = <= ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >(ajversion, ajversion) IS 'greater-than';

CREATE OPERATOR >= (
    LEFTARG = ajversion,
    RIGHTARG = ajversion,
    PROCEDURE = ajversion_ge,
    COMMUTATOR = <= ,
    NEGATOR = < ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >=(ajversion, ajversion) IS 'greater-than-or-equal';

CREATE OPERATOR CLASS btree_ajversion_ops
DEFAULT FOR TYPE ajversion USING btree
AS
        OPERATOR        1       <  ,
        OPERATOR        2       <= ,
        OPERATOR        3       =  ,
        OPERATOR        4       >= ,
        OPERATOR        5       >  ,
        FUNCTION        1       ajversion_cmp(ajversion, ajversion);

CREATE OPERATOR CLASS hash_ajversion_ops
    DEFAULT FOR TYPE ajversion USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hash_ajversion(ajversion);
