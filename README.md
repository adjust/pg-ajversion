# ajversion

A postgres type to store simple version numbers of the form /\d+\.?\d*\.?\d*/
into a 4 byte integer.

### usage

```sql
SELECT '6.7.4'::ajversion;
 ajversion
-----------
 6.7.4
(1 row)

SELECT major('12.5.7'::ajversion), minor('12.5.7'::ajversion), patch('12.5.7'::ajversion);
 major | minor | patch
-------+-------+-------
    12 |     5 |     7
(1 row)

```

### Implementation

Internal storage is a 4 byte unsigned integer. The 12 high bits are used to store the major version
the following 10 bits for the minor version and the last 10 bit for patch level.

This implies that an error is raised when the major version is bigger than 4095 or one of the other levels is
bigger than 1023.

Parsing is done pretty lax, basically we try to find any (at most three) numeric values between non numeric (if at all characters).
