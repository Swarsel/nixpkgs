{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  undmg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-fork";
  version = "2.57.1";

  src = fetchurl {
    url = "https://cdn.fork.dev/mac/Fork-${finalAttrs.version}.dmg";
    hash = "sha256-hIrR655lCKBDkZS6cF7BD+WMvX13T9180rpAfUYc8YA=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{bin,Applications}
    mv Fork.app "$out/Applications/"
    ln -s "$out/Applications/Fork.app/Contents/Resources/fork_cli" "$out/bin/fork"

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Git client";
    homepage = "https://git-fork.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.darwin;
    mainProgram = "fork";
  };
})
