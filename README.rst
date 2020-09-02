@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
``Reputed Tiler`` Window Manager Window Tiler
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

############################################################################################
Simple Window Tiling Replacement for Broken Quicktile in Linux Mint Tara/Ubuntu Bionic/18.04
############################################################################################

=====
Usage
=====

Best called via keybindings.

E.g., to map pressing the Windows key and the left arrow key to repositioning the active,
topmost window, one could run the following shell commands::

  next_index=$(( \
    $(dconf list /org/mate/desktop/keybindings/ | \
      sed "s#custom([0-9]+)/#\1#" | \
      sort -n | \
      tail -1 \
    ) + 1 ))

    dconf write /org/mate/desktop/keybindings/custom${next_index}/name "Reptile Left"
    dconf write /org/mate/desktop/keybindings/custom${next_index}/binding "<Mod4>Left"
    dconf write /org/mate/desktop/keybindings/custom${next_index}/action "${HOME}/.local/bin/reputed-tiler --left"

You can also call from within a terminal window to test on the same, e.g.,::

  ./reputed-tiler --left
  ./reputed-tiler --up
  ./reputed-tiler --right
  ./reputed-tiler --down

Specify the same direction multiple times to cycle through options, e.g.,::

  ./reputed-tiler --left
  ./reputed-tiler --left
  ./reputed-tiler --left
  ./reputed-tiler --left

============
Installation
============

A bevy of options:

- Install locally (relative to user).

- Install systemwide (requires root).

- Install for development (symlinks).

Install Locally
---------------

Download the source and install the application without privilege escalation
by specifying a ``PREFIX``.

Many people prefer to keep their local executables in a sane location, such as
user local bin, i.e., ``~/.local/bin``.

For example, download the repo to a temporary location, install it, and then
remove it.::

    $ tmpdir=$(mktemp -du)
    $ git clone https://github.com/landonb/reputed-tiler.git ${tmpdir} --depth 1
    $ cd ${tmpdir}
    $ PREFIX=${HOME}/.local make install
    $ cd && /bin/rm -rf ${tmpdir}

Install Systemwide
------------------

Run any of these commands as the superuser to install systemwide to ``/usr/local/bin``.

- Install systemwide with a simple ``curl`` command:

  ::

    $ curl -Lo- "https://raw.githubusercontent.com/landonb/reputed-tiler/release/install.sh" | bash

  Which, if you trust me, you could run as root::

    sudo /usr/bin/env bash -c 'curl -Lo- "https://raw.githubusercontent.com/landonb/reputed-tiler/release/install.sh" | bash'

- Install systemwide using
  `bpkg <https://github.com/bpkg/bpkg>`__,
  "Bash package manager":

  ::

    $ bpkg install landonb/reputed-tiler

- Install systemwide using
  `basher <https://github.com/basherpm/basher>`__,
  "a package manager for shell scripts":

  ::

    $ basher install landonb/reputed-tiler

- Install systemwide using
  `clib <https://github.com/clibs/clib>`__,
  "package manager for C projects"
  (which also happens to fetch GitHub repos and run Makefiles):

  ::

    $ clib install landonb/reputed-tiler

Install For Development
-----------------------

Download the source and create symlinks, rather than copying, for development::

    $ git clone https://github.com/landonb/reputed-tiler.git path/to/reputed-tiler --depth 1
    $ cd path/to/reputed-tiler
    $ PREFIX=anywhere/you/like make link

Then you can edit files and re-run the application without reinstalling each time.

Update ``$PATH``
----------------

Add the path of the executable files to PATH to make them easier to access.

- You probably have your own *dotfile* conventions for extending ``PATH``
  and for sourcing shell scripts.

  If not, you can just slap a new line on your Bash startup script
  of the format::

    $ echo 'export PATH="anywhere/you/like/bin:${PATH}"' >> ~/.bashrc

  For example, if you installed to the conventional user local location, run::

    $ echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc

==============
Uninstallation
==============

You can uninstall or unlink similarly to installing or linking:

::

  $ cd path/to/landonb/reputed-tiler

  # And then:

  $ make uninstall

  # Or:

  $ make unlink

Note: You cannot run uninstall or unlink without fetching the source first!
(Although you could just manually remove files yourself, e.g., from
``/usr/local/bin`` and from ``/usr/local/man``, as appropriate.)

===========
Development
===========

Fork this repo, and follow the instructions above to clone the source and
install symlinks for development to your cloned remote. Then just submit
Pull Requests like you normally would.

===========
Online Help
===========

Refer to the man page for complete usage information.

After installing, run::

  $ man reputed-tiler

