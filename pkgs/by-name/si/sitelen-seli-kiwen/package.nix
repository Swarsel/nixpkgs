{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sitelen-seli-kiwen";
  version = "2.2";

  src = fetchzip {
    url = "https://github.com/kreativekorp/sitelen-seli-kiwen/releases/download/${finalAttrs.version}/sitelenselikiwen.zip";
    hash = "sha256-2qxnHjUcfdJG6o/JI4YJP6YVr4/if/0AkMTvco4HWPc=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/{opentype,truetype}
    mv *.eot $out/share/fonts/opentype/
    mv *.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Handwritten sitelen pona font supporting UCSUR";
    homepage = "https://www.kreativekorp.com/software/fonts/sitelenselikiwen/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ somasis ];
    platforms = lib.platforms.all;
  };
})
