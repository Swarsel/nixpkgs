{
  lib,
  autoconf,
  automake,
  gettext,
  libtool,
  makeSetupHook,
}:
makeSetupHook {
  propagatedBuildInputs = [
    autoconf
    automake
    gettext
    libtool
  ];

  name = "autoreconf-hook";
  meta.license = lib.licenses.mit;
} ./autoreconf.sh
