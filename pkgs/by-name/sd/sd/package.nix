{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sd";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "chmln";
    repo = "sd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HK53+1oH3EJm4Tg6BhLtG575FlBREb0OCetIQuCsBNc=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-iOCIX7hq8RqRihVQrVoU2qCTSziuJePxsexkDSCZS9c=";

  postInstall = ''
    installManPage gen/sd.1

    installShellCompletion gen/completions/sd.{bash,fish}
    installShellCompletion --zsh gen/completions/_sd
  '';

  # Only build the CLI; the workspace also has a build-only `xtask` helper.
  cargoBuildFlags = [ "--package=sd-cli" ];
  cargoTestFlags = [ "--package=sd-cli" ];

  meta = {
    description = "Intuitive find & replace CLI (sed alternative)";
    homepage = "https://github.com/chmln/sd";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      amar1729
    ];

    mainProgram = "sd";
  };
})
