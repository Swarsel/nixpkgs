{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hashi-ui";
  version = "1.3.8";

  src = fetchurl {
    url = "https://github.com/jippi/hashi-ui/releases/download/v${finalAttrs.version}/hashi-ui-linux-amd64";
    sha256 = "999a34b6e99657ffc7e6c98a15b8ea744c28420e891a8802c7d99b737752dfb6";
  };

  installPhase = ''
    install -m755 -D $src $out/bin/hashi-ui
  '';

  dontUnpack = true;
  sourceRoot = ".";

  meta = {
    description = "Modern user interface for hashicorp Consul & Nomad";
    homepage = "https://github.com/jippi/hashi-ui";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ numkem ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "hashi-ui";
  };
})
