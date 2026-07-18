{
  lib,
  fetchurl,
  pname,
  sha256,
  stdenvNoCC,
  undmg,
  version,
  metaCommon ? { },
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit sha256;
    url = "https://github.com/sindresorhus/caprine/releases/download/v${version}/Caprine-${version}.dmg";
    name = "Caprine-${version}.dmg";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p "$out/Applications/Caprine.app"
    cp -R . "$out/Applications/Caprine.app"
    mkdir "$out/bin"
    ln -s "$out/Applications/Caprine.app/Contents/MacOS/Caprine" "$out/bin/caprine"
  '';

  sourceRoot = "Caprine.app";

  meta = metaCommon // {
    platforms = with lib.platforms; darwin;
  };
}
