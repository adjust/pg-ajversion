#include "postgres.h"
#include "utils/builtins.h"
#include <ctype.h>
#include <limits.h>
#include <string.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

typedef uint32 ajversion;

#define PG_GETARG_AJVERSION(n) (ajversion) PG_GETARG_UINT32(n)
#define PG_RETURN_AJVERSION(x) PG_RETURN_UINT32(x)
#define MAJOR 4095 /* 12 bit */
#define MINOR 1023 /* 10 bit */
#define BUFLEN 15  /* 3 x 4 digits 2 dots '\0' */

Datum ajversion_in(PG_FUNCTION_ARGS);
Datum semver_out(PG_FUNCTION_ARGS);
Datum ajversion_eq(PG_FUNCTION_ARGS);
Datum ajversion_ne(PG_FUNCTION_ARGS);
Datum ajversion_lt(PG_FUNCTION_ARGS);
Datum ajversion_le(PG_FUNCTION_ARGS);
Datum ajversion_gt(PG_FUNCTION_ARGS);
Datum ajversion_ge(PG_FUNCTION_ARGS);
Datum ajversion_cmp(PG_FUNCTION_ARGS);
Datum ajversion_from_int(PG_FUNCTION_ARGS);
Datum ajversion_major(PG_FUNCTION_ARGS);
Datum ajversion_minor(PG_FUNCTION_ARGS);
Datum ajversion_patch(PG_FUNCTION_ARGS);

static inline ajversion parse_version(char *str);

PG_FUNCTION_INFO_V1(ajversion_in);
Datum ajversion_in(PG_FUNCTION_ARGS)
{
    char *    str = PG_GETARG_CSTRING(0);
    ajversion res = parse_version(str);
    PG_RETURN_AJVERSION(res);
}
PG_FUNCTION_INFO_V1(ajversion_out);
Datum ajversion_out(PG_FUNCTION_ARGS)
{
    ajversion val = PG_GETARG_AJVERSION(0);
    char *    res = (char *) palloc(BUFLEN * sizeof(char));
    char *    ptr = res;
    pg_lltoa(val >> 20 & MAJOR, ptr);

    while (*++ptr != '\0')
        ;
    *ptr++ = '.';
    pg_lltoa(val >> 10 & MINOR, ptr);
    while (*++ptr != '\0')
        ;
    *ptr++ = '.';
    pg_lltoa(val & MINOR, ptr);

    PG_RETURN_CSTRING(res);
}

PG_FUNCTION_INFO_V1(ajversion_eq);
Datum ajversion_eq(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 == arg2);
}

PG_FUNCTION_INFO_V1(ajversion_ne);
Datum ajversion_ne(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 != arg2);
}

PG_FUNCTION_INFO_V1(ajversion_lt);
Datum ajversion_lt(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 < arg2);
}

PG_FUNCTION_INFO_V1(ajversion_le);
Datum ajversion_le(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 <= arg2);
}

PG_FUNCTION_INFO_V1(ajversion_gt);
Datum ajversion_gt(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 > arg2);
}

PG_FUNCTION_INFO_V1(ajversion_ge);
Datum ajversion_ge(PG_FUNCTION_ARGS)
{
    ajversion arg1 = PG_GETARG_AJVERSION(0);
    ajversion arg2 = PG_GETARG_AJVERSION(1);
    PG_RETURN_BOOL(arg1 >= arg2);
}

PG_FUNCTION_INFO_V1(ajversion_cmp);
Datum ajversion_cmp(PG_FUNCTION_ARGS)
{
    ajversion a = PG_GETARG_AJVERSION(0);
    ajversion b = PG_GETARG_AJVERSION(1);

    if (a > b)
        PG_RETURN_INT32(1);
    else if (a == b)
        PG_RETURN_INT32(0);
    else
        PG_RETURN_INT32(-1);
}

PG_FUNCTION_INFO_V1(ajversion_from_int);
Datum ajversion_from_int(PG_FUNCTION_ARGS)
{
    int32 val = PG_GETARG_INT32(0);
    if (val > MAJOR || val < 0)
        elog(ERROR, "major version %d out of range ", val);

    PG_RETURN_AJVERSION(val << 20);
}

PG_FUNCTION_INFO_V1(ajversion_major);
Datum ajversion_major(PG_FUNCTION_ARGS)
{
    ajversion arg = PG_GETARG_AJVERSION(0);
    PG_RETURN_INT32(arg >> 20 & MAJOR);
}

PG_FUNCTION_INFO_V1(ajversion_minor);
Datum ajversion_minor(PG_FUNCTION_ARGS)
{
    ajversion arg = PG_GETARG_AJVERSION(0);
    PG_RETURN_INT32(arg >> 10 & MINOR);
}

PG_FUNCTION_INFO_V1(ajversion_patch);
Datum ajversion_patch(PG_FUNCTION_ARGS)
{
    ajversion arg = PG_GETARG_AJVERSION(0);
    PG_RETURN_INT32(arg & MINOR);
}

static inline ajversion
parse_version(char *str)
{
    ajversion res;
    char *    ptr;
    long int  num;
    int32     parts[] = { 0, 0, 0 };
    int       p       = 0;

    ptr = str;

    for (ptr = str; *ptr != '\0' && p <= 2; ptr++)
    {
        if (*ptr <= '9' && *ptr >= '0')
        {
            num = strtol(ptr, &ptr, 10);
            if (p == 0)
            {
                if (num <= MAJOR)
                    parts[p] = num;
                else
                    elog(ERROR, "major version %ld out of range ", num);
            }
            else
            {
                if (num <= MINOR)
                    parts[p] = num;
                else
                    elog(ERROR, "minor version %ld out of range ", num);
            }
            p++;
        }
    }
    res = parts[0] << 20 | parts[1] << 10 | parts[2];

    return res;
}