{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  nix-update-script,
  olm,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "picoclaw";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "sipeed";
    repo = "picoclaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oMees7EKANS5dkMHIqAHfGcumrNMtTEEA+dmpl8/dLE=";
  };

  buildInputs = [ olm ];
  vendorHash = "sha256-LjTLLeK2M8W34z1M11wKuBAoDI6ciCG3f4FRWAre/sY=";

  preBuild = ''
    rm -rf web/backend/dist
    cp -r ${finalAttrs.passthru.frontend} web/backend/dist

    go generate ./...
  '';

  checkFlags =
    let
      skippedTests = [
        "TestGetVersion"
        "TestCodexCliProvider_MockCLI_Success"
        "TestCodexCliProvider_MockCLI_Error"
        "TestCodexCliProvider_MockCLI_WithModel"
        "TestGatewayStopRefusesNonGatewayAttachedProcess"
        "TestGatewayStatusIgnoresAndRemovesPidFileForNonGatewayProcess"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    ln -sf $out/bin/{backend,picoclaw-launcher}
    install -Dm644 web/picoclaw-launcher.png -t $out/share/icons/hicolor/256x256/apps
    install -Dm444 web/picoclaw-launcher.desktop -t $out/share/applications
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  versionCheckProgramArg = "version";

  passthru = {
    frontend = callPackage ./frontend.nix { picoclaw = finalAttrs.finalPackage; };
    updateScript = nix-update-script { extraArgs = [ "--subpackage=frontend" ]; };
  };

  meta = {
    description = "Tiny, Fast, and Deployable anywhere - automate the mundane, unleash your creativity";
    homepage = "https://github.com/sipeed/picoclaw";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      manfredmacx
      drupol
    ];

    mainProgram = "picoclaw";
  };
})
