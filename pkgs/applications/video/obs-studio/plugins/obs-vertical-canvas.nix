{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  obs-studio,
  qtbase,
}:

stdenv.mkDerivation rec {
  pname = "obs-vertical-canvas";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "Aitum";
    repo = "obs-vertical-canvas";
    rev = version;
    sha256 = "sha256-cWiC4e+ZojTuNAaNwuBQ1pPlchdiuTsVhWMHvcyxx2A=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    curl
    obs-studio
    qtbase
  ];

  cmakeFlags = [
    "-DBUILD_OUT_OF_TREE=On"
    ''-DCMAKE_CXX_FLAGS="-Wno-error=deprecated-declarations"''
  ];

  postInstall = ''
    rm -rf $out/data
    rm -rf $out/obs-plugins
  '';

  dontWrapQtApps = true;

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "Plugin for OBS Studio to add vertical canvas";
    homepage = "https://github.com/Aitum/obs-vertical-canvas";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      flexiondotorg
      jonhermansen
    ];
  };
}
