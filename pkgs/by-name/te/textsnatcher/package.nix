{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gtk3,
  libhandy,
  libportal,
  meson,
  ninja,
  pantheon,
  pkg-config,
  scrot,
  tesseract,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textsnatcher";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "RajSolai";
    repo = "TextSnatcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-phqtPjwKB5BoCpL+cMeHvRLL76ZxQ5T74cpAsgN+/JM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    desktop-file-utils
    wrapGAppsHook3
  ];

  buildInputs = [
    pantheon.granite
    libhandy
    libportal
    gtk3
    glib
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          scrot
          tesseract
        ]
      }
    )
  '';

  meta = {
    description = "Copy Text from Images with ease, Perform OCR operations in seconds";
    homepage = "https://textsnatcher.rf.gd/";
    changelog = "https://github.com/RajSolai/TextSnatcher/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "com.github.rajsolai.textsnatcher";
  };
})
