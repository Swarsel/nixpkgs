{
  lib,
  fetchFromGitHub,
  buildGo127Module,
  fetchPnpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
  versionCheckHook,
}:
buildGo127Module (finalAttrs: {
  pname = "pocket-id";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "pocket-id";
    repo = "pocket-id";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ad8YlWwWeGEwsrx29qpq1asEr4UNN7BueGTBPfFrRuE=";
  };

  vendorHash = "sha256-bQNeocRCmhiV7gwCJppjsNw7K5MnsJMK9M18jf0X/oM=";
  env.CGO_ENABLED = 0;

  preBuild = ''
    cp -r ${finalAttrs.frontend}/lib/pocket-id-frontend/dist frontend/dist
  '';

  checkFlags = [
    # requires networking
    "-skip=TestOidcService_downloadAndSaveLogoFromURL"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    mv $out/bin/cmd $out/bin/pocket-id
  '';

  # required for TestIsURLPrivate
  __darwinAllowLocalNetworking = finalAttrs.doCheck;

  frontend = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "pocket-id-frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpmBuildHook
      pnpm_10
    ];

    env.BUILD_OUTPUT_PATH = "dist";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/pocket-id-frontend
      cp -r frontend/dist $out/lib/pocket-id-frontend/dist

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-LVhTS3ertpGqLMsoodaoEgDb7sK3kTRTVB3KOyvJwpE=";
      pnpm = pnpm_10;
    };

    pnpmWorkspaces = [ "pocket-id-frontend" ];
  };

  ldflags = [
    "-X github.com/pocket-id/pocket-id/backend/internal/common.Version=${finalAttrs.version}"
    "-buildid=${finalAttrs.version}"
  ];

  sourceRoot = "${finalAttrs.src.name}/backend";
  versionCheckProgramArg = "version";

  passthru = {
    tests = {
      inherit (nixosTests) pocket-id;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
      ];
    };
  };

  meta = {
    description = "OIDC provider with passkeys support";
    homepage = "https://pocket-id.org";
    changelog = "https://github.com/pocket-id/pocket-id/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      gepbird
      marcusramberg
      tmarkus
      ymstnt
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pocket-id";
  };
})
