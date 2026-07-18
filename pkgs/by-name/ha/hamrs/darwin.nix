{
  lib,
  fetchurl,
  _7zz,
  meta,
  pname,
  stdenvNoCC,
  undmg,
  version,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;
  inherit meta;

  src = fetchurl {
    url = "https://hamrs-releases.s3.us-east-2.amazonaws.com/${finalAttrs.version}/HAMRS-${finalAttrs.version}.dmg";
    hash = "sha256-IQ7r2OLwJW4auiNDddzZ99jXxrtPw3uYoGIUEHU1gtc=";
  };

  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
})
