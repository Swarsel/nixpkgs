{
  lib,
  fetchFromGitHub,
  bombardier,
  buildGoModule,
  nix-update-script,
  testers,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "bombardier";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "codesenberg";
    repo = "bombardier";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FoaiUky0WcipkGN8KIpSd+iizinlqtHC5lskvNCnx/Y=";
  };

  vendorHash = "sha256-SezGoDM4xzOj1y/qmvlngYKOVdJnxBD4l9LPVErevUI=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  subPackages = [
    "."
  ];

  versionCheckProgramArg = "--version";

  passthru.tests = {
    version = testers.testVersion {
      package = bombardier;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast cross-platform HTTP benchmarking tool written in Go";
    homepage = "https://github.com/codesenberg/bombardier";
    changelog = "https://github.com/codesenberg/bombardier/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "bombardier";
  };
})
