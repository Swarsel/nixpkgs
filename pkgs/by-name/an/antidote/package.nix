{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "antidote";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "mattmc3";
    repo = "antidote";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cLgfRprMuMl+yH5GtgOxP51pKReGebxKynzbvR8XlI0=";
  };

  installPhase = ''
    runHook preInstall
    install -D antidote --target-directory=$out/share/antidote
    install -D antidote.zsh --target-directory=$out/share/antidote
    install -D functions/* --target-directory=$out/share/antidote/functions
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;

  meta = {
    description = "Zsh plugin manager made from the ground up thinking about performance";
    homepage = "https://getantidote.github.io/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hitsmaxft
      NanamiNakano
    ];

    platforms = lib.platforms.all;
  };
})
