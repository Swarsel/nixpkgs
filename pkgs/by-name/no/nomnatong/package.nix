{
  lib,
  fetchFromGitHub,
  installFonts,
  nix-update-script,
  python3Packages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nomnatong";
  version = "5.17";

  src = fetchFromGitHub {
    owner = "nomfoundation";
    repo = "font";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z/Q0WLr+kSDIiAwqrZUokoiWUp5qP25rXgqlPlMo0hg=";
  };

  nativeBuildInputs = [
    installFonts
    python3Packages.afdko
    python3Packages.fonttools
  ];

  buildPhase = ''
    runHook preBuild

    makeotf -r -f font.pfa -omitMacNames -ff features.txt -mf FontMenuNameDB -ga -ci UnicodeVariationSequences.txt
    otf2ttf NomNaTong-Regular.otf
    sfntedit -d DSIG NomNaTong-Regular.otf

    runHook postBuild
  '';

  sourceRoot = "${finalAttrs.src.name}/src";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hán-Nôm Coded Character Set and Nom Na Tong Regular Reference Font";
    homepage = "https://nomfoundation.org/nom-tools/Nom-Font";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.eclairevoyant ];
    platforms = lib.platforms.all;
  };
})
