{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "checkra1n";
  version = "0.12.4";

  src = fetchurl {
    url = "https://assets.checkra.in/downloads/linux/cli/x86_64/dac9968939ea6e6bfbdedeb41d7e2579c4711dc2c5083f91dced66ca397dc51d/checkra1n";
    sha256 = "07f5glwwlrpdvj8ky265q8fp3i3r4mz1vd6yvvxnnvpa764rdjfs";
  };

  installPhase = ''
    install -dm755 "$out/bin"
    install -m755 $src $out/bin/${pname}
  '';

  dontUnpack = true;

  meta = {
    description = "Jailbreak for iPhone 5s though iPhone X, iOS 12.0 and up";
    homepage = "https://checkra.in/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
  };
}
