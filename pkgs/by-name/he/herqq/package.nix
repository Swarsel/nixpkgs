{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
}:

stdenv.mkDerivation rec {
  pname = "herqq";
  version = "unstable-20-06-26";

  src = fetchFromGitHub {
    owner = "ThomArmax";
    repo = "HUPnP";
    rev = "c8385a8846b52def7058ae3794249d6b566a41fc";
    sha256 = "FxN/QlLB3sZ6Vn/9VIKNUntX/B4+crQZ7t760pwFqY8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
  ];

  sourceRoot = "${src.name}/herqq";

  meta = {
    description = "Software library for building UPnP devices and control points";
    homepage = "http://herqq.org";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
