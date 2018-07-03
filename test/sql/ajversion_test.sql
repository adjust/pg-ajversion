SELECT '0.5.9'::ajversion;
SELECT '1.5'::ajversion;
SELECT '15'::ajversion;
SELECT '15'::ajversion > '18.9'::ajversion;
SELECT '15'::ajversion > '2.7'::ajversion;
SELECT '4095.1023.1023'::ajversion > '0.0.1'::ajversion;

SELECT 'unknown'::ajversion;
SELECT '   '::ajversion;

SELECT '545 major 456 minor 466 patch'::ajversion;

SELECT '545 x 456 x 466'::ajversion;


SELECT 12.5::ajversion;
SELECT 1235::ajversion;

SELECT '12.5.7'::ajversion > 12::ajversion;
SELECT '12.5.7'::ajversion < 13::ajversion;

SELECT major('12.5.7'::ajversion), minor('12.5.7'::ajversion), patch('12.5.7'::ajversion);