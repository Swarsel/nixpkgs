{
  lib,
  fetchurl,
  gccStdenv,
}:

gccStdenv.mkDerivation (finalAttrs: {
  pname = "ii";
  version = "2.0";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/ii-${finalAttrs.version}.tar.gz";
    hash = "sha256-T2evzSCMB5ObiKrb8hSXpwKtCgf5tabOhh+fOf/lQls=";
  };

  makeFlags = [ "CC:=$(CC)" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Irc it, simple FIFO based irc client";
    homepage = "https://tools.suckless.org/ii/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "ii";
  };
})
