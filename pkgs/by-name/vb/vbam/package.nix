{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cairo,
  cmake,
  ffmpeg_7,
  gettext,
  gsettings-desktop-schemas,
  gtk3,
  libGL,
  libGLU,
  openal,
  pkg-config,
  sfml_2,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "visualboyadvance-m";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "visualboyadvance-m";
    repo = "visualboyadvance-m";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/yvwr3Of4aox4pOBwiC4gUzGsrPDwaFYPgJVivuOAvo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    ffmpeg_7
    gettext
    libGLU
    libGL
    openal
    SDL2
    sfml_2
    zip
    zlib
    wxwidgets_3_2
    gtk3
    gsettings-desktop-schemas
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_FFMPEG" true)
    (lib.cmakeBool "ENABLE_LINK" true)
    (lib.cmakeFeature "SYSCONFDIR" "etc")
    (lib.cmakeBool "ENABLE_SDL" true)
  ];

  meta = {
    description = "Merge of the original Visual Boy Advance forks";
    homepage = "https://www.visualboyadvance-m.org/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      lassulus
      netali
    ];

    platforms = lib.platforms.linux;
    mainProgram = "visualboyadvance-m";
  };
})
