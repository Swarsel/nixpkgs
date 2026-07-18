{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  libsForQt5,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "twmn";
  version = "2025_10_23";

  src = fetchFromGitHub {
    owner = "sboli";
    repo = "twmn";
    tag = version;
    hash = "sha256-/yQtwoolGhtn19I+vus27OjaZgXXfhnWKQi+rUMozCY=";
  };

  postPatch = ''
    sed -i s/-Werror// twmnd/twmnd.pro
  '';

  nativeBuildInputs = [
    pkg-config
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    boost
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp bin/* "$out/bin"

    runHook postInstall
  '';

  meta = {
    description = "Notification system for tiling window managers";
    homepage = "https://github.com/sboli/twmn";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.matejc ];
    platforms = with lib.platforms; linux;
  };
}
