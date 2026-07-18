{
  lib,
  fetchurl,
  mkFranzDerivation,
}:

mkFranzDerivation rec {
  pname = "franz";
  version = "5.11.0";

  src = fetchurl {
    url = "https://github.com/meetfranz/franz/releases/download/v${version}/franz_${version}_amd64.deb";
    sha256 = "sha256-4+HeH9lY5/2fswSwzMPM1Idllj01zU7nmlLOMYfcSsU=";
  };

  name = "Franz";

  meta = {
    description = "Free messaging app that combines chat & messaging services into one application";
    homepage = "https://meetfranz.com";
    license = lib.licenses.free;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };
}
