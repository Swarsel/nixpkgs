{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "delve";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "go-delve";
    repo = "delve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g7Lyi+lZZ818p4yINoJ12bdCY8sTwxaU/eRkuofnqnU=";
  };

  patches = [
    ./disable-fortify.diff
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  # Disable tests on Darwin as they require various workarounds.
  #
  # - Tests requiring local networking fail with or without sandbox,
  #   even with __darwinAllowLocalNetworking allowed.
  # - CGO_FLAGS warnings break tests' expected stdout/stderr outputs.
  # - DAP test binaries exit prematurely.
  doCheck = !stdenv.hostPlatform.isDarwin;

  preCheck = ''
    XDG_CONFIG_HOME=$(mktemp -d)
  '';

  postInstall = ''
    # add symlink for vscode golang extension
    # https://github.com/golang/vscode-go/blob/master/docs/debugging.md#manually-installing-dlv-dap
    ln $out/bin/dlv $out/bin/dlv-dap

    installShellCompletion --cmd dlv \
      --bash <($out/bin/dlv completion bash) \
      --fish <($out/bin/dlv completion fish) \
      --zsh <($out/bin/dlv completion zsh)
  '';

  # delve doesn't support --version
  doInstallCheck = false;
  hardeningDisable = [ "fortify" ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/dlv" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Debugger for the Go programming language";
    homepage = "https://github.com/go-delve/delve";
    changelog = "https://github.com/go-delve/delve/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "dlv";
  };
})
