##### version
GCCLT_MAJOR   := 0
GCCLT_MINOR   := 1
GCCLT_PATCH   := 1
GCCLT_SUFFIX  :=

##### src files
INCEXPORTS  := gcclt.h
LIBSRCFILES := \
	mem.cc \
	stream.cc \
#	$(wildcard subdir/*.c) \

##### lib files
LIBNAME     := gcclt.so
STATICLIBNAME := gcclt_static.a

##### dirs
BUILDDIR ?= $(abspath ../build)
INCDIR := $(BUILDDIR)/include
LIBDIR := $(BUILDDIR)/lib
OBJDIR := $(BUILDDIR)/obj

##### target files
INCTARGETS := $(INCEXPORTS:%=$(INCDIR)/%)  # include/gcclt.h
LIBSONAME  := $(LIBNAME:%=%.$(GCCLT_MAJOR))
LIBTARGET  := $(LIBNAME:%=%.$(GCCLT_MAJOR).$(GCCLT_MINOR).$(GCCLT_PATCH))
STATICLIBTARGET := $(STATICLIBNAME)
LIBOBJ     := $(LIBSRCFILES:%.cc=$(OBJDIR)/%.o)
DEPFILES   := $(LIBOBJ:%.o=%.d)
LDFLAGS    += -lpthread -lrt -ldl

## ENV
# CUDA_LIB := /usr/local/cuda/lib
# DTK_LIB := /opt/dtk/hsa/lib
CNCL_LIB := /usr/local/neuware/lib
CNCL_LIB64 := /usr/local/neuware/lib64

# cuda
ifdef CUDA_LIB
	CUDARTLIB  ?= cudart_static
	ifeq ($(CUDARTLIB), cudart_static)
		# Use compatibility shim only with static cudart; see https://github.com/NVIDIA/nccl/issues/658
		LIBSRCFILES += enhcompat.cc
	endif

	CFLAGS += -DCUDA_RUNTIME=1
	LDFLAGS    += -L${CUDA_LIB} -l$(CUDARTLIB)
endif

# dtk
ifdef DTK_LIB
	CFLAGS += -DROCM_RUNTIME=1
	LDFLAGS    += -L${DTK_LIB}
endif

# cncl
ifdef CNCL_LIB
	CFLAGS += -DCNCL_RUNTIME=1
	LDFLAGS    += -L${CNCL_LIB} -L$(CNCL_LIB64)
endif

##### rules
build : lib staticlib

lib : $(INCTARGETS) $(LIBDIR)/$(LIBTARGET)

staticlib : $(LIBDIR)/$(STATICLIBTARGET)

ALWAYS_REBUILD:

-include $(DEPFILES)
$(LIBDIR)/$(LIBTARGET) $(LIBDIR)/$(STATICLIBTARGET) : $(LIBOBJ)

$(INCDIR)/gcclt.h : gcclt.h
# GCCLT_VERSION(X,Y,Z) ((X) * 10000 + (Y) * 100 + (Z))
	@$(eval GCCLT_VERSION := $(shell printf "%d%02d%02d" $(GCCLT_MAJOR) $(GCCLT_MINOR) $(GCCLT_PATCH)))
	mkdir -p $(INCDIR)
	@printf "Generating %-35s > %s\n" $< $@
	sed -e "s/\$${gcclt:Major}/$(GCCLT_MAJOR)/g" \
	    -e "s/\$${gcclt:Minor}/$(GCCLT_MINOR)/g" \
	    -e "s/\$${gcclt:Patch}/$(GCCLT_PATCH)/g" \
	    -e "s/\$${gcclt:Suffix}/$(GCCLT_SUFFIX)/g" \
	    -e "s/\$${gcclt:Version}/$(GCCLT_VERSION)/g" \
	    $< > $@



$(LIBDIR)/$(LIBTARGET): $(LIBOBJ)
	@printf "Linking    %-35s > %s\n" $(LIBTARGET) $@
	mkdir -p $(LIBDIR)
	$(CXX) $(CXXFLAGS) -shared -Wl,--no-as-needed -Wl,-soname,$(LIBSONAME) -o $@ $(LIBOBJ) $(LDFLAGS) ${CFLAGS}
	ln -sf $(LIBSONAME) $(LIBDIR)/$(LIBNAME)
	ln -sf $(LIBTARGET) $(LIBDIR)/$(LIBSONAME)

$(LIBDIR)/$(STATICLIBTARGET): $(LIBOBJ)
	@printf "Archiving  %-35s > %s\n" $(STATICLIBTARGET) $@
	mkdir -p $(LIBDIR)
	ar cr $@ $(LIBOBJ)

$(INCDIR)/%.h : %.h
	@printf "Grabbing   %-35s > %s\n" $< $@
	mkdir -p $(INCDIR)
	install -m 644 $< $@

$(INCDIR)/gcclt_%.h : include/gcclt_%.h
	@printf "Grabbing   %-35s > %s\n" $< $@
	mkdir -p $(INCDIR)
	install -m 644 $< $@

$(OBJDIR)/%.o : %.cc $(INCTARGETS)
	@printf "Compiling  %-35s > %s\n" $< $@
	mkdir -p `dirname $@`
	$(CXX) -I. -I$(INCDIR) $(CXXFLAGS) -Iinclude -c $< -o $@
	@$(CXX) -I. -I$(INCDIR) $(CXXFLAGS) -Iinclude -M $< > $(@:%.o=%.d.tmp)
	@sed "0,/^.*:/s//$(subst /,\/,$@):/" $(@:%.o=%.d.tmp) > $(@:%.o=%.d)
	@sed -e 's/.*://' -e 's/\\$$//' < $(@:%.o=%.d.tmp) | fmt -1 | \
                sed -e 's/^ *//' -e 's/$$/:/' >> $(@:%.o=%.d)
	@rm -f $(@:%.o=%.d.tmp)

clean :
	rm -rf ${INCDIR} ${LIBDIR} ${PKGDIR} ${OBJDIR}

install : build
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	cp -P -v $(BUILDDIR)/lib/lib* $(PREFIX)/lib/
	cp -v $(BUILDDIR)/include/* $(PREFIX)/include/

FILESTOFORMAT := $(shell find . -name ".\#*" -prune -o \( -name "*.cc" -o -name "*.h" \) -print | grep -v -E 'ibvwrap.h|nvmlwrap.h|gcclt.h')
