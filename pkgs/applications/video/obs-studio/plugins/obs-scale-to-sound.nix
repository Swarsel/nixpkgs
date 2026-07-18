{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
}:

stdenv.mkDerivation rec {
  pname = "obs-scale-to-sound";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "dimtpap";
    repo = "obs-scale-to-sound";
    tag = version;
    hash = "sha256-El5lwQfc33H9KvjttJyjakzRizjLoGz2MbkiRm4zm8E=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio ];

  cmakeFlags = [
    "-DBUILD_OUT_OF_TREE=On"
  ];

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "OBS filter plugin that scales a source reactively to sound levels";
    homepage = "https://github.com/dimtpap/obs-scale-to-sound";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ flexiondotorg ];
  };
}
