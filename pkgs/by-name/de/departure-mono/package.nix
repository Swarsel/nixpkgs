{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "departure-mono";
  version = "1.500";

  src = fetchzip {
    url = "https://github.com/rektdeckard/departure-mono/releases/download/v${finalAttrs.version}/DepartureMono-${finalAttrs.version}.zip";
    hash = "sha256-XYL76L266MKqClxfbPn/C6+x/vcs7AD56DtiDmQam2A=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m 444 *.otf -t $out/share/fonts/otf
    install -D -m 444 *.woff -t $out/share/fonts/woff
    install -D -m 444 *.woff2 -t $out/share/fonts/woff2

    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/DepartureMono-${finalAttrs.version}";

  meta = {
    description = "Departure Mono is a monospaced pixel font with a lo-fi technical vibe";
    homepage = "https://departuremono.com/";
    changelog = "https://github.com/rektdeckard/departure-mono/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
