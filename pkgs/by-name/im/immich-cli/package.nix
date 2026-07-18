{
  lib,
  stdenv,
  immich,
  jq,
  makeWrapper,
  nodejs,
  pnpmConfigHook,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (immich) version src pnpmDeps;
  pname = "immich-cli";

  nativeBuildInputs = [
    jq
    makeWrapper
    nodejs
    pnpmConfigHook
    immich.pnpm
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter @immich/cli... build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local -r packageOut="$out/lib/node_modules/@immich/cli"

    pnpm --filter @immich/cli deploy --prod --no-optional "$packageOut"

    makeWrapper '${lib.getExe nodejs}' "$out/bin/immich" \
      --add-flags "$packageOut/dist/index.js"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    inherit (nodejs.meta) platforms;
    description = "Self-hosted photo and video backup solution (command line interface)";
    homepage = "https://immich.app/docs/features/command-line-interface";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ jvanbruegge ];
    mainProgram = "immich";
  };
})
