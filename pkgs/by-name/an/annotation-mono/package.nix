{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "annotation-mono";
  version = "0.4";

  src = fetchzip {
    url = "https://github.com/qwerasd205/AnnotationMono/releases/download/v${finalAttrs.version}/AnnotationMono_v${finalAttrs.version}.zip";
    hash = "sha256-6DEYTYAENNY/5oD9us9f7VtPae/it7qrFC3/UT1J+Qg=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/truetype $src/dist/ttf/*.ttf
    install -D -m444 -t $out/share/fonts/truetype $src/dist/variable/AnnotationMono-VF.ttf
    install -D -m444 -t $out/share/fonts/opentype $src/dist/otf/*.otf

    runHook postInstall
  '';

  meta = {
    description = "Lovingly crafted handwriting-style monospace font";
    homepage = "https://github.com/qwerasd205/AnnotationMono";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.theonlymrcat ];
    platforms = lib.platforms.all;
  };
})
