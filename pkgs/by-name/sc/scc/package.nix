{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "scc";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "boyter";
    repo = "scc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gOr09UzPfmNDUqvGJtmXYdn0gWfcvvVyoBfyRBDSy88=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd scc \
      --bash <($out/bin/scc completion bash) \
      --fish <($out/bin/scc completion fish) \
      --zsh <($out/bin/scc completion zsh)
  '';

  # scc has a scripts/ sub-package that's for testing.
  excludedPackages = [ "scripts" ];

  meta = {
    description = "Very fast accurate code counter with complexity calculations and COCOMO estimates written in pure Go";
    homepage = "https://github.com/boyter/scc";

    license = with lib.licenses; [
      mit
    ];

    maintainers = with lib.maintainers; [
      sigma
    ];
  };
})
