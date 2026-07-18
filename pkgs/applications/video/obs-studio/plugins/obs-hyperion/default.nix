{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  flatbuffers,
  libGL,
  obs-studio,
  pkg-config,
  qtbase,
}:

stdenv.mkDerivation rec {
  pname = "obs-hyperion";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "hyperion-project";
    repo = "hyperion-obs-plugin";
    rev = version;
    sha256 = "sha256-UAfjafoZhhhHRSo+eUBLhHaCmn2GYFcYyRb9wHIp/9I=";
  };

  patches = [ ./check-state-changed.patch ];

  nativeBuildInputs = [
    cmake
    flatbuffers
    pkg-config
  ];

  buildInputs = [
    obs-studio
    flatbuffers
    libGL
    qtbase
  ];

  cmakeFlags = [
    "-DOBS_SOURCE=${obs-studio.src}"
    "-DGLOBAL_INSTALLATION=ON"
    "-DUSE_SYSTEM_FLATBUFFERS_LIBS=ON"
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error" ];

  preConfigure = ''
    rm -rf external/flatbuffers
  '';

  dontWrapQtApps = true;

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "OBS Studio plugin to connect to a Hyperion.ng server";
    homepage = "https://github.com/hyperion-project/hyperion-obs-plugin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ algram ];
  };
}
