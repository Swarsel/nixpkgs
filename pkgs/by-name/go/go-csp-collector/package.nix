{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "go-csp-collector";
  version = "0.0.22";

  src = fetchFromGitHub {
    owner = "jacobbednarz";
    repo = "go-csp-collector";
    tag = "v${finalAttrs.version}";
    hash = "sha256-30+rLt0VonbwP3I09OrAxiCqrUuIvGivE3+6sQ/hnRo=";
  };

  vendorHash = "sha256-gto2lD3atZTy5QMECarLBWQR7Z1bBlFAoJtJYrzg7bY=";

  postInstall = ''
    install -Dm644 init/go-csp-collector.service $out/lib/systemd/system/go-csp-collector.service

    substituteInPlace $out/lib/systemd/system/go-csp-collector.service \
      --replace-fail "/usr/local/bin/go-csp-collector" "$out/bin/go-csp-collector"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Rev=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "-version";

  passthru = {
    tests.service = nixosTests.go-csp-collector;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A content security policy violation collector written in Golang";
    homepage = "https://github.com/jacobbednarz/go-csp-collector";
    changelog = "https://github.com/jacobbednarz/go-csp-collector/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stepbrobd ];
    mainProgram = "go-csp-collector";
  };
})
