{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-moegirl";
  version = "20260712";

  src = fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/${finalAttrs.version}/moegirl.dict.yaml";
    hash = "sha256-d4I2xyyWh9vry7vMkE1E19G55w/uenqbTspymdy0dqw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/moegirl.dict.yaml

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "RIME dictionary file for entries from zh.moegirl.org.cn";
    homepage = "https://github.com/outloudvi/mw2fcitx/releases";
    changelog = "https://github.com/outloudvi/mw2fcitx/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      mit # the tool packaging dictionary
      cc-by-nc-sa-30 # moegirl wiki itself
    ];

    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
