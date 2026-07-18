{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  libGL,
  libsForQt5,
  nix-update-script,
  povray,
  replaceVars,
  testers,
  zlib,
}:

/*
  To use additional parts libraries
  set the variable LEOCAD_LIB=/path/to/libs/ or use option -l /path/to/libs/
*/

let
  parts = fetchurl {
    hash = "sha256-Uy7YYE7LdcmgEGbt6DlljS3QCQxjcviLApFuu1p9GZ8=";
    url = "https://web.archive.org/web/20250709230715/https://library.ldraw.org/library/updates/complete.zip";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "leocad";
  version = "25.09";

  src = fetchFromGitHub {
    owner = "leozide";
    repo = "leocad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Utiy9JBKaPddb2yNv1Ta61KIB1vCsayZlxagn3or5UE=";
  };

  patches = [
    (replaceVars ./povray.patch {
      inherit povray;
    })
  ];

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    zlib
    libGL
  ];

  propagatedBuildInputs = [ povray ];

  qmakeFlags = [
    "INSTALL_PREFIX=${placeholder "out"}"
    "DISABLE_UPDATE_CHECK=1"
  ];

  qtWrapperArgs = [
    "--set-default LEOCAD_LIB ${parts}"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "env QT_QPA_PLATFORM=minimal ${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CAD program for creating virtual LEGO models";
    homepage = "https://www.leocad.org/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      peterhoeg
    ];

    platforms = lib.platforms.linux;
    mainProgram = "leocad";
  };
})
