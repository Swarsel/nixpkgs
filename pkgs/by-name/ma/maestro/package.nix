{
  lib,
  stdenv,
  fetchurl,
  jre_headless,
  makeWrapper,
  unzip,
  writeScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maestro";
  version = "2.6.1";

  src = fetchurl {
    url = "https://github.com/mobile-dev-inc/maestro/releases/download/cli-${finalAttrs.version}/maestro.zip";
    hash = "sha256-NECCX1FPU3xqlrz13plXgMKkp/g6QyCP3JXU8f7PrTs=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    mkdir $out
    unzip $src -d $out
    mv $out/maestro/* $out
    rm -rf $out/maestro
  '';

  postFixup = ''
    wrapProgram $out/bin/maestro --prefix PATH : "${lib.makeBinPath [ jre_headless ]}"
  '';

  dontUnpack = true;

  passthru.updateScript = writeScript "update-maestro" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    set -o errexit -o nounset -o pipefail

    NEW_VERSION=$(curl --silent https://api.github.com/repos/mobile-dev-inc/maestro/releases | jq 'first(.[].tag_name | ltrimstr("cli-") | select(contains("dev.") | not))' --raw-output)

    update-source-version "maestro" "$NEW_VERSION" --print-changes
  '';

  meta = {
    description = "Mobile UI Automation tool";
    homepage = "https://maestro.mobile.dev/";
    changelog = "https://github.com/mobile-dev-inc/maestro/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ SubhrajyotiSen ];
    platforms = lib.platforms.all;
    mainProgram = "maestro";
  };
})
