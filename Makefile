.PHONY : all clean

default : src.build
install : src.install
BUILDDIR ?= $(abspath ./build)
ABSBUILDDIR := $(abspath $(BUILDDIR))
TARGETS := src
clean: ${TARGETS:%=%.clean}
	rm -r build
test.build: src.build

${BUILDDIR}/%.txt: %.txt
	@printf "Copying    %-35s > %s\n" $< $@
	mkdir -p ${BUILDDIR}
	cp $< $@

src.%:
	${MAKE} -C src $* BUILDDIR=${ABSBUILDDIR}