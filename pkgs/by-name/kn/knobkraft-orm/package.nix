{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  boost,
  cmake,
  cppcheck,
  curlFull,
  git,
  glew,
  glib,
  gtk3,
  icu,
  lerc,
  libbtbb,
  libdatrie,
  libdeflate,
  libepoxy,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libwebp,
  libxdmcp,
  libxkbcommon,
  libxtst,
  pcre2,
  pkg-config,
  python312,
  sqlite,
  util-linux,
  webkitgtk_4_1,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "KnobKraft-orm";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "christofmuc";
    repo = "knobkraft-orm";
    tag = finalAttrs.version;
    hash = "sha256-1mPeiey0hbJmg5k9R06wnDIGDDxbOfRixQ0zoFa4zYA=";
    fetchSubmodules = true;
  };

  # Issue has been raised and should be resolved with next release.
  # CMakeLists.txt needs three more lines to properly build.
  patches = [ ./temporary.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gtk3
    glew
    webkitgtk_4_1
    cppcheck
    icu
    python312
    glib
    curlFull
    boost
    libbtbb
    libsysprof-capture
    pcre2
    alsa-lib
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    libxdmcp
    lerc
    libxkbcommon
    libepoxy
    libxtst
    sqlite
    git
    libdeflate
    xz
    libwebp
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INTERPROCEDURAL_OP" "off")
    (lib.cmakeFeature "PYTHON_VERSION_TO_EMBED" "${python312.pythonVersion}")
  ];

  makeFlags = [
    "package"
  ];

  meta = {
    description = "Modern FOSS MIDI Sysex Librarian";
    homepage = "https://github.com/christofmuc/KnobKraft-orm";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      backtail
    ];

    platforms = lib.platforms.linux;
    mainProgram = "KnobKraftOrm";
  };
})
