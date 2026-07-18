{
  lib,
  stdenv,
  fetchFromGitHub,
  libnotify,
  makeWrapper,
  mpv,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tomato-c";
  version = "0-unstable-2025-11-11";

  src = fetchFromGitHub {
    owner = "gabrielzschmitz";
    repo = "Tomato.C";
    rev = "590224cbbf0f53f09d33080c4e83797a11ad02d1";
    hash = "sha256-TVvCqWWjfFHcFOMEO9frfrs9638cOjkV8yvqavdzdmI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libnotify
    mpv
    ncurses
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  postFixup = ''
    for file in $out/bin/*; do
      wrapProgram $file \
        --prefix PATH : ${
          lib.makeBinPath [
            libnotify
            mpv
          ]
        }
    done
  '';

  installFlags = [
    "CPPFLAGS=$NIX_CFLAGS_COMPILE"
    "LDFLAGS=$NIX_LDFLAGS"
  ];

  meta = {
    description = "Pomodoro timer written in pure C";
    homepage = "https://github.com/gabrielzschmitz/Tomato.C";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
    platforms = lib.platforms.unix;
    mainProgram = "tomato";
  };
})
