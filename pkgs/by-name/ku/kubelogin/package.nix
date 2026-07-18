{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubelogin,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubelogin";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "kubelogin";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-s9W5wvA4L0Qbn5vimLU03oqx10XqCybE3YvC9gV3y7A=";
  };

  patches = [
    ./disable-nix-incompatible-test.patch
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-CWgvbN8NnroSVqfKF8UG6kXqVWrQ0TmKwri1f218K+M=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/kubelogin completion bash >kubelogin.bash
    $out/bin/kubelogin completion fish >kubelogin.fish
    $out/bin/kubelogin completion zsh >kubelogin.zsh
    installShellCompletion kubelogin.{bash,fish,zsh}
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X main.gitTag=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = kubelogin;
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Kubernetes credential plugin implementing Azure authentication";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kubelogin";
  };
})
