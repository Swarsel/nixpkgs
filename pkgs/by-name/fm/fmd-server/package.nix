{
  lib,
  stdenv,
  fetchFromGitLab,
  buildGoModule,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  versionCheckHook,
}:
buildGoModule (
  finalAttrs:
  let
    inherit (finalAttrs.finalPackage.passthru) ui;
  in
  {
    pname = "fmd-server";
    version = "0.15.0";

    src = fetchFromGitLab {
      owner = "fmd-foss";
      repo = "fmd-server";
      tag = "v${finalAttrs.version}";
      hash = "sha256-EzhXrB15lRtDnFicdH7fjpcm1BYoAb1SBeylGSub69s=";
    };

    vendorHash = "sha256-cFIg9mOSQbrYHW4kg4aTeTaF+gy1jNpAlg8qepb81Jc=";

    preBuild = ''
      cp -r ${ui}/${ui.distRoot} web/
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];

    pnpmDeps = fetchPnpmDeps {
      inherit (ui) pname src;
      inherit pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-vKSKPwOkb7TwDUlkl8lUvO6tLKp2NyBQ0BGxThUN2P8=";
      sourceRoot = "${finalAttrs.src.name}/${ui.pnpmRoot}";
    };

    versionCheckProgramArg = "version";

    passthru.ui = stdenv.mkDerivation {
      inherit (finalAttrs) version src pnpmDeps;
      pname = "${finalAttrs.pname}-web-ui";

      nativeBuildInputs = [
        nodejs
        pnpmConfigHook
        pnpm_10
      ];

      buildPhase = ''
        runHook preBuild

        pushd web
        pnpm build
        popd

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r '${ui.pnpmRoot}/${ui.distRoot}' "$out"

        runHook postInstall
      '';

      distRoot = "dist";
      pnpmRoot = "web";
    };

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Server to communicate with the FindMyDevice app and save the latest (encrypted) location";
      homepage = "https://fmd-foss.org/";
      license = lib.licenses.gpl3Plus;

      maintainers = with lib.maintainers; [
        j0hax
        jthulhu
      ];

      mainProgram = "fmd-server";
      downloadPage = "https://gitlab.com/fmd-foss/fmd-server";
      teams = [ lib.teams.ngi ];
    };
  }
)
