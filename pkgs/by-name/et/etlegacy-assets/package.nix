{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "etlegacy-assets";
  version = "2.83.2";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/etlegacy/etmain
    cp -r . $out/lib/etlegacy/etmain/
    runHook postInstall
  '';

  sourceRoot = ".";

  srcs =
    let
      fetchAsset =
        { asset, hash }:
        fetchurl {
          inherit hash;
          url = "https://mirror.etlegacy.com/etmain/${asset}";
        };
    in
    [
      (fetchAsset {
        asset = "pak0.pk3";
        hash = "sha256-cSlmsg4GUj/oFBlRZQDkmchrK0/sgjhW3b0zP8s9JuU=";
      })
      (fetchAsset {
        asset = "pak1.pk3";
        hash = "sha256-VhD9dJAkQFtEJafOY5flgYe5QdIgku8R1IRLQn31Pl0=";
      })
      (fetchAsset {
        asset = "pak2.pk3";
        hash = "sha256-pIq3SaGhKrTZE3KGsfI9ZCwp2lmEWyuvyPZOBSzwbz4=";
      })
    ];

  unpackCmd = "cp -r $curSrc \${curSrc##*-}";

  meta = {
    description = "ET: Legacy assets only";

    longDescription = ''
      ET: Legacy, an open source project fully compatible client and server
      for the popular online FPS game Wolfenstein: Enemy Territory - whose
      gameplay is still considered unmatched by many, despite its great age.
    '';

    homepage = "https://etlegacy.com";
    license = with lib.licenses; [ cc-by-nc-sa-30 ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
