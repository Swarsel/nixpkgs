{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "terraform-docs";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "terraform-docs";
    repo = "terraform-docs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yroGYLZX1MnCTVmDiTbWDNnwLcmTOT/jYECmFy/ZmRk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-k4xypyNk80EXH823oItjc45kkupjTSXHybnMrKEgFvs=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/terraform-docs completion bash >terraform-docs.bash
    $out/bin/terraform-docs completion fish >terraform-docs.fish
    $out/bin/terraform-docs completion zsh >terraform-docs.zsh
    installShellCompletion terraform-docs.{bash,fish,zsh}
  '';

  excludedPackages = [ "scripts" ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Utility to generate documentation from Terraform modules in various output formats";
    homepage = "https://github.com/terraform-docs/terraform-docs/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zimbatm
      anthonyroussel
    ];

    mainProgram = "terraform-docs";
  };
})
