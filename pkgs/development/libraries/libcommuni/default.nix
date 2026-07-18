{
  lib,
  stdenv,
  fetchFromGitHub,
  qmake,
  qtbase,
  qtdeclarative,
  which,
}:

stdenv.mkDerivation rec {
  pname = "libcommuni";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "communi";
    repo = "libcommuni";
    rev = "v${version}";
    sha256 = "sha256-9eYJpmjW1J48RD6wVJOHmsAgTbauNeeCrXe076ufq1I=";
  };

  nativeBuildInputs = [
    qmake
    which
  ];

  buildInputs = [
    qtbase
    qtdeclarative
  ];

  configureFlags = [
    "-config"
    "release"
  ]
  # Build mixes up dylibs/frameworks if one is not explicitly specified.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-config"
    "qt_framework"
  ];

  preConfigure = ''
    sed -i -e 's|/bin/pwd|pwd|g' configure
  '';

  # The tests fail on darwin because of install_name if they run
  # before the frameworks are installed.
  doCheck = false;
  doInstallCheck = true;
  # Hack to avoid TMPDIR in RPATHs.
  preFixup = "rm -rf lib";
  dontUseQmakeConfigure = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;
  installCheckTarget = "check";

  meta = {
    description = "Cross-platform IRC framework written with Qt";
    homepage = "https://communi.github.io";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
