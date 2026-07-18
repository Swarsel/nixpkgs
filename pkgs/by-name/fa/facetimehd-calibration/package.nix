{
  lib,
  curl,
  stdenvNoCC,
  unrar-wrapper,
}:

stdenvNoCC.mkDerivation {
  pname = "facetimehd-calibration";
  version = "5.1.5769";

  nativeBuildInputs = [
    curl
    unrar-wrapper
  ];

  __structuredAttrs = true;
  builder = ./builder.sh;
  # This is a special sort of fixed-output derivation
  outputHash = "sha256-KQBIlpa68wjQNgBiEnLtl6iEYseNrTlSdq9wiNni16k=";
  outputHashMode = "recursive";

  meta = {
    description = "facetimehd calibration";
    homepage = "https://support.apple.com/kb/DL1837";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];

    maintainers = with lib.maintainers; [
      alexshpilkin
      womfoo
    ];

    platforms = lib.platforms.all;
  };
}
