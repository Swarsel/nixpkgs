{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libexif,
  libfm,
  libpthread-stubs,
  libxcb,
  libxdmcp,
  lxqt-build-tools,
  lxqt-menu-data,
  menu-cache,
  pkg-config,
  qttools,
  wrapQtAppsHook,
  qtx11extras ? null,
  version ? "2.4.0",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libfm-qt";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "libfm-qt";
    tag = finalAttrs.version;

    hash =
      {
        "1.4.0" = "sha256-QxPYSA7537K+/dRTxIYyg+Q/kj75rZOdzlUsmSdQcn4=";
        "2.4.0" = "sha256-gfyskv/TpAdBES0+O1MrrkQqTDqtAGtDMIwv3NF7pnE=";
      }
      ."${finalAttrs.version}";
  };

  postPatch = lib.optionals (version == "1.4.0") ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    libxdmcp
    libexif
    libfm
    libpthread-stubs
    libxcb
    lxqt-menu-data
    menu-cache
  ]
  ++ (lib.optionals (lib.versionAtLeast "2.0.0" finalAttrs.version) [ qtx11extras ]);

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Core library of PCManFM-Qt (Qt binding for libfm)";
    homepage = "https://github.com/lxqt/libfm-qt";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.lxqt ];
  };
})
