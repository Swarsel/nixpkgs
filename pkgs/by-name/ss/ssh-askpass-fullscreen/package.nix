{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk2,
  openssh,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ssh-askpass-fullscreen";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "atj";
    repo = "ssh-askpass-fullscreen";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1GER+SxTpbMiYLwFCwLX/hLvzCIqutyvQc9DNJ7d1C0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gtk2
    openssh
  ];

  meta = {
    description = "Small, fullscreen SSH askpass GUI using GTK+2";
    homepage = "https://github.com/atj/ssh-askpass-fullscreen";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ssh-askpass-fullscreen";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
