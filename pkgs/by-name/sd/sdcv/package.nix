{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gettext,
  glib,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdcv";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "Dushistov";
    repo = "sdcv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-EyvljVXhOsdxIYOGTzD+T16nvW7/RNx3DuQ2OdhjXJ4=";
  };

  postPatch = ''
    # https://github.com/Dushistov/sdcv/pull/104
    substituteInPlace src/stardict_lib.cpp --replace-fail \
      "gchar *nextchar = g_utf8_next_char(sWord)" \
      "gchar *nextchar = const_cast<gchar*>(g_utf8_next_char(sWord))"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
    gettext
    readline
  ];

  env.NIX_CFLAGS_COMPILE = "-D__GNU_LIBRARY__";

  preInstall = ''
    mkdir locale
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Console version of StarDict";
    homepage = "https://dushistov.github.io/sdcv/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "sdcv";
  };
})
