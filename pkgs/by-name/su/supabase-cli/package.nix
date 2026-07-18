{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "supabase-cli";
  version = "2.109.1";

  src = fetchFromGitHub {
    owner = "supabase";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wTqvbcYC2QeeUXUzkmvUin0oXulmhMXIiyNCXaWqPSQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-qfQgcdRv4GHmZWQWth3Hqknlr9yCjRkZFO0p2jeZG0A=";
  doCheck = false; # Root Go package does not have any tests.

  postInstall = ''
    mv $out/bin/{cli,supabase}

    installShellCompletion --cmd supabase \
      --bash <($out/bin/supabase completion bash) \
      --fish <($out/bin/supabase completion fish) \
      --zsh <($out/bin/supabase completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X=github.com/supabase/cli/internal/utils.Version=${finalAttrs.version}"
  ];

  # Supabase is in the process of porting the CLI to TS, for now we continue with the Go cli.
  sourceRoot = "${finalAttrs.src.name}/apps/cli-go";
  subPackages = [ "." ];

  passthru.updateScript = nix-update-script {
    # Fetch versions from GitHub releases to detect pre-releases and
    # avoid updating to them.
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "CLI for interacting with supabase";
    homepage = "https://github.com/supabase/cli";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gerschtli
      kashw2
      yuannan
    ];

    mainProgram = "supabase";
  };
})
