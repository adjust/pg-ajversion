#http://blog.pgxn.org/post/4783001135/extension-makefiles pg makefiles
EXTENSION = ajversion
EXTVERSION = $(shell grep default_version $(EXTENSION).control | \
                sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
PG_CONFIG ?= pg_config
DATA = $(wildcard *--*.sql)
PGXS := $(shell $(PG_CONFIG) --pgxs)
MODULE_big = ajversion
OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c))
SQLSRC = $(wildcard sql/*.sql)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test --load-language=plpgsql \
			   --load-extension=$(EXTENSION)

include $(PGXS)

all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: $(SQLSRC)
	echo "-- complain if script is sourced in psql, rather than via CREATE EXTENSION" > $@
	echo "\echo Use \"CREATE EXTENSION ${EXTENSION}\" to load this file. \quit" >> $@
	echo "" >> $@
	cat $^ >> $@