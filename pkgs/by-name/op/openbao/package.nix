{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  installShellFiles,
  nix-update-script,
  nixosTests,
  stdenvNoCC,
  versionCheckHook,
  withHsm ? stdenvNoCC.hostPlatform.isLinux,
  withUi ? true,
}:

buildGoModule (finalAttrs: {
  pname = "openbao";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "openbao";
    repo = "openbao";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FJ+34HeRT025EFwFXY8ewfnJbQirqFb3j+kPNxpGOA4=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-O0xx61S0KEk5QB/NsV+kBlErvVuKBfI/81o29rDye1w=";

  postConfigure = lib.optionalString withUi ''
    cp -r --no-preserve=mode ${finalAttrs.passthru.ui} http/web_ui
  '';

  postInstall = ''
    mv $out/bin/openbao $out/bin/bao

    # https://github.com/posener/complete/blob/9a4745ac49b29530e07dc2581745a218b646b7a3/cmd/install/bash.go#L8
    installShellCompletion --bash --name bao <(echo complete -C "$out/bin/bao" bao)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X github.com/openbao/openbao/version.GitCommit=${finalAttrs.src.rev}"
    "-X github.com/openbao/openbao/version.fullVersion=${finalAttrs.version}"
    "-X github.com/openbao/openbao/version.buildDate=1970-01-01T00:00:00Z"
  ];

  proxyVendor = true;
  subPackages = [ "." ];
  tags = lib.optional withHsm "hsm" ++ lib.optional withUi "ui";
  versionCheckProgram = "${placeholder "out"}/bin/bao";

  passthru = {
    tests = { inherit (nixosTests) openbao; };
    ui = callPackage ./ui.nix { };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "ui"
      ];
    };
  };

  meta = {
    description = "Open source, community-driven fork of Vault managed by the Linux Foundation";
    homepage = "https://www.openbao.org/";
    changelog = "https://github.com/openbao/openbao/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      brianmay
      emilylange
    ];

    mainProgram = "bao";
  };
})
