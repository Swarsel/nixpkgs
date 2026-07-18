{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "ee";
  version = "1.5.2-unstable-2024-06-20";

  src = fetchFromGitHub {
    owner = "freebsd";
    repo = "freebsd-src";
    rev = "0667538b888c1171932c6cf28b62fc19d393e119";
    hash = "sha256-nMhHXeoam9VtUuhhi0eoGZfcW9zZhpYQKVYbkAbfgc0=";
    rootDir = "contrib/ee";
  };

  postPatch = ''
    substituteInPlace create.make --replace-fail "/usr/include/curses.h" "${ncurses.dev}/include/ncurses.h"
    substituteInPlace create.make --replace-fail "-lcurses" "-lncurses"
  '';

  buildInputs = [ ncurses ];
  env.NIX_CFLAGS_COMPILE = "-DHAS_UNISTD=1 -DHAS_STDLIB=1 -DHAS_SYS_WAIT=1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ee $out/bin/ee

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "classic curses text editor";

    longDescription = ''
      An easy to use text editor. Intended to be usable with little or no
      instruction. Provides a terminal (curses based) interface. Features
      pop-up menus. Born in HP-UX, included in FreeBSD.
    '';

    homepage = "https://man.freebsd.org/cgi/man.cgi?ee";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ qweered ];
    platforms = lib.platforms.unix;
    mainProgram = "ee";
  };
}
