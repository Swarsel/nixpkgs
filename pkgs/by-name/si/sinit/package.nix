{
  lib,
  stdenv,
  fetchgit,
  rcinit ? "/etc/rc.d/rc.init",
  rcreboot ? null,
  rcshutdown ? "/etc/rc.d/rc.shutdown",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sinit";
  version = "1.1";

  src = fetchgit {
    url = "https://git.suckless.org/sinit/";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VtXkgixgElKKOT26uKN9feXDVjjtSgTWvcgk5o5MLmw=";
  };

  buildInputs = [
    (lib.getOutput "static" stdenv.cc.libc)
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  preConfigure =
    ""
    + (lib.optionalString (
      rcinit != null
    ) ''sed -re 's@(rcinitcmd[^"]*")[^"]*"@\1${rcinit}"@' -i config.def.h; '')
    + (lib.optionalString (
      rcshutdown != null
    ) ''sed -re 's@(rc(reboot|poweroff)cmd[^"]*")[^"]*"@\1${rcshutdown}"@' -i config.def.h; '')
    + (lib.optionalString (
      rcreboot != null
    ) ''sed -re 's@(rc(reboot)cmd[^"]*")[^"]*"@\1${rcreboot}"@' -i config.def.h; '');

  meta = {
    description = "Very minimal Linux init implementation from suckless.org";
    homepage = "https://tools.suckless.org/sinit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "sinit";
    downloadPage = "https://git.suckless.org/sinit";
  };
})
