{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  mednafen,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mednaffe";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "AmatCoder";
    repo = "mednaffe";
    rev = finalAttrs.version;
    hash = "sha256-ZizW0EeY/Cc68m87cnbLAkx3G/ULyFT5b6Ku2ObzFRU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    mednafen
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH ':' "${mednafen}/bin"
    )
  '';

  enableParallelBuilding = true;

  meta = {
    description = "GTK-based frontend for mednafen emulator";
    homepage = "https://github.com/AmatCoder/mednaffe";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "mednaffe";
  };
})
