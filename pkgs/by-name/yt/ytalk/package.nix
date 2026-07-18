{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ytalk";
  version = "3.3.0";

  src = fetchurl {
    url = "ftp://ftp.ourproject.org/pub/ytalk/ytalk-${finalAttrs.version}.tar.gz";
    sha256 = "1d3jhnj8rgzxyxjwfa22vh45qwzjvxw1qh8fz6b7nfkj3zvk9jvf";
  };

  buildInputs = [ ncurses ];
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  meta = {
    description = "Terminal based talk client";
    homepage = "http://ytalk.ourproject.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ taeer ];
    platforms = lib.platforms.unix;
    mainProgram = "ytalk";
  };
})
