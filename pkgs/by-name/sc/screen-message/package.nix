{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "screen-message";
  version = "0.29";

  src = fetchFromGitHub {
    owner = "nomeata";
    repo = "screen-message";
    rev = finalAttrs.version;
    hash = "sha256-fwKle+aXZuiNo5ksrigj7BGLv2fUILN2GluHHZ6co6s=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ gtk3 ];
  # screen-message installs its binary in $(prefix)/games per default
  makeFlags = [ "execgamesdir=$(out)/bin" ];

  meta = {
    description = "Displays a short text fullscreen in an X11 window";
    homepage = "https://www.joachim-breitner.de/en/projects#screen-message";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.fpletz ];
    platforms = lib.platforms.unix;
    mainProgram = "sm";
  };
})
