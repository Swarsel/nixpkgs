{
  lib,
  stdenv,
  fetchurl,
  squashfsTools,
}:

# This derivation roughly follows the update-ffmpeg script that ships with the official Vivaldi
# downloads at https://vivaldi.com/download/

let
  sources = {
    aarch64-linux = fetchurl {
      hash = "sha256-4RmVOQ9emlRyzAGxeiSLwvkGv+7R/mKLVYm5IWXqLpo=";
      url = "https://api.snapcraft.io/api/v1/snaps/download/XXzVIXswXKHqlUATPqGCj2w2l7BxosS8_116.snap";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-YEE7oF8NLGDCQ3gpY5z6B+7xDxcOumjOzwUztJUM+/s=";
      url = "https://api.snapcraft.io/api/v1/snaps/download/XXzVIXswXKHqlUATPqGCj2w2l7BxosS8_117.snap";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chromium-codecs-ffmpeg-extra";
  version = "2026-05-18";
  src = sources."${stdenv.hostPlatform.system}";
  buildInputs = [ squashfsTools ];

  installPhase = ''
    install -vD chromium-ffmpeg-git-${finalAttrs.version}/chromium-ffmpeg/libffmpeg.so $out/lib/libffmpeg.so
  '';

  unpackPhase = ''
    unsquashfs -dest . $src
  '';

  passthru = {
    inherit sources;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Additional support for proprietary codecs for Vivaldi and other chromium based tools";
    homepage = "https://ffmpeg.org/";
    license = lib.licenses.lgpl21;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      betaboon
      cawilliamson
      fptje
      sarahec
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
