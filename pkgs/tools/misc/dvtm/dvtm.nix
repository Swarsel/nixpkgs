{
  lib,
  stdenv,
  ncurses,
  pname,
  src,
  version,
  customConfig ? null,
  patches ? [ ],
}:
stdenv.mkDerivation {

  inherit
    pname
    version
    src
    patches
    ;

  outputs = [
    "out"
    "man"
  ];

  postPatch = lib.optionalString (customConfig != null) ''
    cp ${builtins.toFile "config.h" customConfig} ./config.h
  '';

  nativeBuildInputs = [ ncurses ];
  buildInputs = [ ncurses ];
  makeFlags = [ "PREFIX=$(out)" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    CFLAGS = "-D_DARWIN_C_SOURCE";
  };

  prePatch = ''
    substituteInPlace Makefile \
      --replace /usr/share/terminfo $out/share/terminfo
  '';

  meta = {
    description = "Dynamic virtual terminal manager";
    homepage = "http://www.brain-dump.org/projects/dvtm";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
