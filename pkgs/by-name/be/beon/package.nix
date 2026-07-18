{
  lib,
  fetchFromGitHub,
  installFonts,
  mkfontdir,
  mkfontscale,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "beon";
  version = "2024-02-26";

  src = fetchFromGitHub {
    owner = "noirblancrouge";
    repo = "Beon";
    rev = "c0379c80a3b7d01532413f43f49904b2567341ac";
    hash = "sha256-jBLVVykHFJamOVF6GSRnQqYixqOrw5K1oV1B3sl4Zoc=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [
    mkfontscale
    mkfontdir
    installFonts
  ];

  preInstall = "rm -r docs/proof";

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  postInstall = ''
    mkfontdir $out/share/fonts
    mkfontscale $out/share/fonts
  '';

  dontBuild = true;

  meta = {
    description = "Neon stencil typeface";
    homepage = "https://noirblancrouge.com/fonts/beon-display";
    changelog = "https://github.com/noirblancrouge/Beon#changelog";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ raboof ];
    platforms = lib.platforms.all;
  };
}
