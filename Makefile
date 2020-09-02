# USAGE:
#
#   System-wide install
#   -------------------
#
#   If you'd like to install this package and forget about it, try:
#
#     sudo make install
#
#   and it'll install to /usr/local/bin.
#
#   User install
#   ------------
#
#   If you'd like to install this package locally,
#   e.g., to $HOME/.local/bin, try:
#
#     PREFIX=~/.local make install
#
#   and you'll find the package files under ~/.local/bin.
#
#   Or, modify `PREFIX` to install to any <path>/bin of your choosing.
#
#   Developer install
#   -----------------
#
#   If you want to install this package and to also be able to edit it, try:
#
#     PREFIX=<path/to/this/repo> make link
#
#   which makes symlinks to the underlying scripts, rather than copying them.

# SOURCE FILES:
#
#   After `make install`, you can delete the source files, as the Bash
#   scripts and man pages will have been copied to other directories.
#
#   After `make link`, obviously, you'll want to keep this directory,
#   as any changes you make to its scripts will be reflected in your Bash
#   environment (after reloading or resourcing your shell, of course).

# SHOILERPLATE:
#
#   This Makefile, and its install.sh wrapper, are copied from a shell
#   script boilerplate project at github.com/landonb/shoilerplate.

# PLUMBING:
#
#   This Makefile is pretty simple. It looks inside the bin/ directory
#   and copies (make install) or symlinks (make link) the files therein;
#   or it removes previously copied or symlinked files (make uninstall
#   and make unlink). It does the same for shell scripts (bin/) as it
#   does for man pages (man/man[0-9]). This script is probably longer
#   than it needs because Makefile. But at least it's simple to read.

PREFIX ?= /usr/local
TARGET := $(abspath $(PREFIX)/bin)
MANDIR := $(abspath $(PREFIX)/man)

# LEARNING: `make` appends MAKEFILE_LIST with paths as it reads makefiles.
#   https://ftp.gnu.org/old-gnu/Manuals/make/html_node/make_17.html
# So this is the path to this Makefile from the user's working directory.

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))

# This is the path to the directory wherein this Makefile is located,
#   in case the user is running make from another directory.

mkfile_base := $(dir $(mkfile_path))

# Pressure user to commit.
# 0. First check whether in git repo or not -- could be unpacked archive.
# 1. Check whether repo has staged changes (not yet committed).
# 2. Check whether working tree has changes that could be staged.
# 3. Check whether combo of index and tracked files in working tree
#    have changes with respect to HEAD.
# 4. Check for “untracked” (including ignored files).
# With thanks to:
#   https://stackoverflow.com/questions/2657935/
#     checking-for-a-dirty-index-or-untracked-files-with-git
#	&& [[ ! -d .git ]] || (
IS_DIRTY_GIT := $(shell \
	true \
	&& cd $(mkfile_base) \
	&& [ ! -d .git ] || ( \
		true \
		&& $$(git diff-index --quiet --cached HEAD --) \
		&& $$(git diff-files --quiet) \
		&& $$(git diff-index --quiet HEAD --) \
		&& ( u="$(git ls-files --others)" && test -z "$u" ) \
	) \
	; echo $$? \
)
ifneq ($(IS_DIRTY_GIT),0)
# Prints as:
#   Makefile:83: *** Clean ur repo to continue. Hammer time.  Stop.
# make so weird.
# Also, cannot indent without it looking like a recipe. Bah!
# (Thankfully, syntax highlighting helps distinguish between blocks.)
$(error Clean ur repo to continue. Hammer time)
endif

# The first target is the .DEFAULT, which we'll use to print available targets.
# Note that I tried lifting code from the Bash completion script,
#   /usr/share/bash-completion/completions/make
# but for some reason its sed command is failing on me.
# Fortunately, I found a decent solution elsewhere:
#   https://unix.stackexchange.com/questions/230047/how-to-list-all-targets-in-make
# However, this approach includes 'Makefile' as a target.
#   make -qp |
#     awk -F':' '/^[a-zA-Z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' |
#     sort |
#     /usr/bin/env sed 's/^/  /'
# so I'll just go the simpler route and parse the .PHONY list.
.PHONY : help
help:
	@echo "Please choose a target for make:"
	@make -qp \
		| grep "^\.PHONY" \
		| /usr/bin/env sed 's/^\.PHONY: //' \
		| tr ' ' "\n" \
		| sort \
		| /usr/bin/env sed 's/^/  /'

# LEARNING: .PHONY specifies that the target name is an internal
#   Makefile name, and not a file name, otherwise Make will first
#   check for a file of the same name as the target.
#     https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
#   So while not always required, it's a best practice to use it.
.PHONY : release
release:
	sed -i'' "s/^\( *\)VERSION=.*/\1VERSION=`cat VERSION`/" bin/* install.sh
	sed -i'' "s/^\( *\)\"version\":.*/\1\"version\": \"`cat VERSION`\",/" package.json
	git add bin/* install.sh package.json
	git commit -m "Release `cat VERSION`" || true
	git push release release
	git tag `cat VERSION`
	git push --tags

.PHONY : install
install: prepareManDirs installBin installMan compileMan

.PHONY : uninstall
uninstall: uninstallBin uninstallMan removeEmpties removeManBaseMaybe compileMan

.PHONY : link
link: prepareManDirs linkBin linkMan compileMan

.PHONY : unlink
unlink: unlinkBin unlinkMan removeEmpties removeManBaseMaybe compileMan

.PHONY : installBin
installBin:
	@mkdir -p $(TARGET) || exit 1
	@find bin/ \( -type f -o -type l \) -exec install {} $(TARGET)/ \;

.PHONY : uninstallBin
uninstallBin:
	@cd $(mkfile_base)/bin \
		&& find . \( -type f -o -type l \) -exec /usr/bin/env bash -c \
			"[[ -f $(TARGET)/{} && ! -h $(TARGET)/{} ]] && /bin/rm -f $(TARGET)/{} || true" \;

.PHONY : linkBin
linkBin:
	@mkdir -p $(TARGET) || exit 1
	@cd $(mkfile_base)/bin \
		&& find . -type f -exec /usr/bin/env bash -c \
			"ln -sf \$$(realpath $(mkfile_base)/bin/{}) $(TARGET)/" \; \
		&& find . -type l -exec /usr/bin/env bash -c \
			"ln -sf $(mkfile_base)/bin/{} $(TARGET)/" \;

.PHONY : unlinkBin
unlinkBin:
	@cd $(mkfile_base)/bin \
		&& find . \( -type f -o -type l \) -exec /usr/bin/env bash -c \
			"[[ -h $(TARGET)/{} ]] && /bin/rm -f $(TARGET)/{} || true" \;

# Both `uninstall` and `unlink` attempt to remove the
# directory hierarchy that this Makefile may have made.
.PHONY : removeEmpties
removeEmpties:
	@[ -d $(TARGET) ] && find $(TARGET) -type d -empty -delete || true
	@[ -d $(MANDIR) ] && find $(MANDIR) -type d -empty -delete || true

# NOTE: make does something magic with $(shell ...). It seems like
# it runs shell commands *before* other commands in the rule. E.g.,
# if we combined this rule and removeEmpties, such that we had:
#   removeEmpties:
#     @[ -d $(MANDIR) ] && find $(MANDIR) -type d -empty -delete || true
#     @echo $(shell /usr/bin/env ls -1 $(MANDIR))
# surprisingly, the ls command shows the empty directories that you'd
# think the previous line had deleted! So make these separate rules.
.PHONY : removeManBaseMaybe
removeManBaseMaybe:
	@$(eval num_remaining := $(shell /usr/bin/env ls -1 $(MANDIR) 2> /dev/null | wc -l))
	@[ $(num_remaining) -eq 1 ] \
		&& [ -f $(MANDIR)/index.db ] \
		&& /bin/rm $(MANDIR)/index.db \
		&& rmdir $(MANDIR) \
		|| true

.PHONY : prepareManDirs
prepareManDirs:
	@mkdir -p $(MANDIR)
	@# NOTE: Using s~~~ sed delimiters, not conventional s///, so we can
	@#       avoid needing to escape path characters.
	@find man/ \
		-iname "*.[0-9]" \
		-exec /usr/bin/env bash -c \
			"echo {} | /usr/bin/env sed -E 's~.*([0-9])$$~$(MANDIR)/man\1~'" \; \
	| sort \
	| uniq \
	| xargs mkdir -p

.PHONY : installMan
installMan:
	@find man/ \
		-iname "*.[0-9]" \
		-exec /usr/bin/env bash -c \
			"echo {} \
				| /usr/bin/env sed -E 's~(.*)([0-9])$$~install \1\2 $(MANDIR)/man\2/~' \
				| source /dev/stdin" \;

.PHONY : uninstallMan
uninstallMan:
	@cd $(mkfile_base)/man \
		&& find . \
			-iname "*.[0-9]" \
			-exec /usr/bin/env bash -c \
				"echo {} \
					| /usr/bin/env sed -E 's~(.*)([0-9])$$~[[ -f $(MANDIR)/man\2/\1\2 \&\& ! -h $(MANDIR)/man\2/\1\2 ]] \&\& /bin/rm $(MANDIR)/man\2/\1\2 || true~' \
					| source /dev/stdin" \;

.PHONY : linkMan
linkMan:
	@find man/ \
		-iname "*.[0-9]" \
		-exec /usr/bin/env bash -c \
			"echo {} \
				| /usr/bin/env sed -E 's~(.*)([0-9])$$~/bin/ln -sf \$$(realpath $(mkfile_base)/\1\2) $(MANDIR)/man\2/~' \
				| source /dev/stdin" \;

.PHONY : unlinkMan
unlinkMan:
	@cd $(mkfile_base)/man \
		&& find . \
			-iname "*.[0-9]" \
			-exec /usr/bin/env bash -c \
				"echo {} \
					| /usr/bin/env sed -E 's~(.*)([0-9])$$~[[ -h $(MANDIR)/man\2/\1\2 ]] \&\& /bin/rm $(MANDIR)/man\2/\1\2 || true~' \
					| source /dev/stdin" \;

.PHONY : compileMan
compileMan:
	@mandb > /dev/null 2>&1

# vim:tw=0:ts=2:sw=2:noet:ft=make:

