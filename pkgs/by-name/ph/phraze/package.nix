{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  phraze,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "phraze";
  version = "0.3.25";

  src = fetchFromGitHub {
    owner = "sts10";
    repo = "phraze";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Eeyf3+zJYMRbfeTj+LdxMGEeouvvky6cAmADFqIoRNo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-NJOVWIUObmjjamRDZsj7V6xKsfRfUeUqCiKBv/vNiEY=";
  doCheck = true;

  postInstall = ''
    installManPage target/man/phraze.1

    installShellCompletion --cmd phraze \
      --bash target/completions/phraze.bash \
      --fish target/completions/phraze.fish \
      --zsh target/completions/_phraze
  '';

  passthru = {
    tests = {
      version = testers.testVersion { package = phraze; };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Generate random passphrases";
    homepage = "https://github.com/sts10/phraze";
    changelog = "https://github.com/sts10/phraze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      x123
      donovanglover
    ];

    mainProgram = "phraze";
  };
})
