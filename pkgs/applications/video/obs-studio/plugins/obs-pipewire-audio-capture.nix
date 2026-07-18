{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  obs-studio,
  pipewire,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "obs-pipewire-audio-capture";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "dimtpap";
    repo = "obs-pipewire-audio-capture";
    rev = version;
    sha256 = "sha256-GrfogPsqpQ976Gcc4JVdslAAWTj49PdspwVp/JXYXSQ=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    obs-studio
    pipewire
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=./lib"
    "-DCMAKE_INSTALL_DATADIR=./share"
  ];

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "Audio device and application capture for OBS Studio using PipeWire";
    homepage = "https://github.com/dimtpap/obs-pipewire-audio-capture";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Elinvention
      fazzi
    ];
  };
}
