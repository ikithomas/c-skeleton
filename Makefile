# flags for the cc compile
CFLAGS=-g -O2 -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLAGS)

# Options used when linking a library
LIBS=-ldl $(OPTLIBS)

# ?= Optional variable
PREFIX?=/usr/local

# All source file paths
SOURCES=$(wildcard src/**/*.c src/*.c)

# All object file paths
OBJECTS=$(patsubst %.c,%.o,$(SOURCES))

# All test source file paths
TEST_SRC=$(wildcard tests/*_tests.c)

# All test object file paths
TESTS=$(patsubst %.c,%,$(TEST_SRC))

# The target, i.e. the library that I am trying to build
TARGET=build/libYOUR_LIBRARY.a
SO_TARGET=$(patsubst %.a,%.so,$(TARGET))

# The first target is what make runs by default when no target is given
all: $(TARGET) $(SO_TARGET) tests

# Changing options for only one target
# Wextra is useful for finding bug
dev: CFLAGS=-g -Wall -Isrc -Wall -Wextra $(OPTFLAGS)
dev: all

# Whatever matching TARGET will be built
$(TARGET): CFLAGS += -fPIC
$(TARGET): build $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

build:
	@mkdir -p build
	@mkdir -p bin

################################################################################
# Unit testing
###
.PHONY: tests
tests: CFLAGS += $(TARGET)
tests: $(TESTS)
	sh ./tests/runtests.sh

# The Cleaner
clean:
	rm -rf build $(OBJECTS) $(TESTS)
	rm -f tests/tests.log
	find . -name ".gc*" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`

# The Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$PREFIX)/lib/
