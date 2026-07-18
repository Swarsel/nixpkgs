{ callPackage, ccextractor }:

callPackage ./common.nix { } {
  pname = "tdarr-server";
  component = "server";

  hashes = {
    darwin_arm64 = "sha256-wRuTyUmRWYEMMCgScr+yTbsU1VSXypz9T8WhgyZE2TM=";
    darwin_x64 = "sha256-xnOI47sMZlTJNkTFrQCsioLQsjeOCVu1RZLgpoiRhTU=";
    linux_arm64 = "sha256-G3jK5pqKMKiciajaMku9S/q7upWcxmfXwZQ1tWhGaDg=";
    linux_x64 = "sha256-iTxbPJ1XmmGInpCz4cbwnW8u5uV3DpMyXGMuKmGXOlc=";
  };

  includeInPath = [ ccextractor ];
  installIcons = true;
}
