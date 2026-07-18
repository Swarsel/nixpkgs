{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fluidsynth,
  ftgl,
  glew,
  gtk3,
  libwebp,
  lua,
  mpg123,
  pkg-config,
  sfml_2,
  which,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slade";
  version = "3.2.12";

  src = fetchFromGitHub {
    owner = "sirjuddington";
    repo = "SLADE";
    tag = finalAttrs.version;
    hash = "sha256-HSfK4vBGoRlljJ7JEJLjzSLmevIqllTwJ6z8bXPUp0w=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    which
    zip
    wrapGAppsHook3
  ];

  buildInputs = [
    wxwidgets_3_2
    gtk3
    sfml_2
    fluidsynth
    curl
    ftgl
    glew
    lua
    mpg123
    libwebp
  ];

  cmakeFlags = [
    "-DwxWidgets_LIBRARIES=${wxwidgets_3_2}/lib"
    (lib.cmakeFeature "CL_WX_CONFIG" (lib.getExe' (lib.getDev wxwidgets_3_2) "wx-config"))
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GDK_BACKEND : x11
    )
  '';

  meta = {
    description = "Doom editor";
    homepage = "http://slade.mancubus.net/";
    changelog = "https://github.com/sirjuddington/SLADE/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only; # https://github.com/sirjuddington/SLADE/issues/1754
    maintainers = with lib.maintainers; [ Gliczy ];
    platforms = lib.platforms.linux;
    mainProgram = "slade";
  };
})
