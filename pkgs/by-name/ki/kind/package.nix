{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kind,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kind";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kind";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3icwtfwlSkYOEw9bzEhKJC7OtE1lnBjZSYp+cC/2XNc=";
  };

  patches = [
    # fix kernel module path used by kind
    ./kernel-module-path.patch
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-tRpylYpEGF6XqtBl7ESYlXKEEAt+Jws4x4VlUVW8SNI=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kind \
      --bash <($out/bin/kind completion bash) \
      --fish <($out/bin/kind completion fish) \
      --zsh <($out/bin/kind completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  passthru = {
    tests.version = testers.testVersion {
      package = kind;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Kubernetes IN Docker - local clusters for testing Kubernetes";
    homepage = "https://github.com/kubernetes-sigs/kind";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      rawkode
    ];

    mainProgram = "kind";
  };
})
