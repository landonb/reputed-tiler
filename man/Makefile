RONN := ronn
PAGES := reputed-tiler.1

all: $(PAGES)

reputed-tiler.1: reputed-tiler.1.ronn
	$(RONN) -r $<

# Note: Because Makefail (ugh) this runs before recipes
#   (like shell would, before functions).
HAS_RONN := $(shell (command -v $(RONN) > /dev/null 2>&1 ; echo $$?))
ifneq ($(HAS_RONN),0)
$(error 'Install ronn! Try: `gem install ronn`. Get ronn it!')
endif

# vim:tw=0:ts=2:sw=2:noet:ft=make:

