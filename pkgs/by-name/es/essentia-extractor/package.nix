{
  lib,
  stdenv,
  fetchurl,
}:
let
  arch_table = {
    "i686-linux" = "linux-i686";
    "x86_64-linux" = "linux-x86_64";
  };

  sha_table = {
    "i686-linux" = "46deb0a053b4910c4e68737a7b6556ff5360260c8f86652f91a0130445f5c949";
    "x86_64-linux" = "d9902aadac4f442992877945da2a6fe8d6ea6b0de314ca8ac0c28dc5f253f7d8";
  };

  throwSystem = throw "Unsupported system: ${stdenv.system}";
  arch = arch_table.${stdenv.system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "essentia-extractor";
  version = "2.1_beta2";

  src = fetchurl {
    url = "https://ftp.acousticbrainz.org/pub/acousticbrainz/essentia-extractor-v${finalAttrs.version}-${arch}.tar.gz";
    sha256 = sha_table.${stdenv.system} or throwSystem;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp streaming_extractor_music $out/bin
  '';

  unpackPhase = "unpackFile $src ; export sourceRoot=.";

  meta = {
    description = "AcousticBrainz audio feature extractor";
    homepage = "https://acousticbrainz.org/download";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ lovesegfault ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "streaming_extractor_music";
  };
})
