{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  curl,
  installShellFiles,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hydra-check";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "hydra-check";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5nZnY/EA5SF3KNZbsvNGn77cOgEZsBpxBJwiREyF/fE=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-DN2LSYCR9QL1090C6dt21EOq9aUtZkAvxh4B6KYXPAU=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd hydra-check \
      --bash <($out/bin/hydra-check --shell-completion bash) \
      --fish <($out/bin/hydra-check --shell-completion fish) \
      --zsh <($out/bin/hydra-check --shell-completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.tests.mainCommand =
    testers.runCommand # allows internet access
      {
        nativeBuildInputs = [
          finalAttrs.finalPackage
          curl
          cacert # for https connectivity
        ];

        name = "hydra-check-test";

        # only runs the test when internet access is confirmed:
        script = ''
          set -e
          if curl hydra.nixos.org > /dev/null; then
            hydra-check
          else
            echo "no internet access, skipping test"
          fi
          touch $out
        '';
      };

  meta = {
    description = "Check hydra for the build status of a package";
    homepage = "https://github.com/nix-community/hydra-check";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      makefu
      artturin
      bryango
      doronbehar
    ];

    mainProgram = "hydra-check";
  };
})
