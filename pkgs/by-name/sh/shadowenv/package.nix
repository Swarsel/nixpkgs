{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shadowenv";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "shadowenv";
    rev = finalAttrs.version;
    hash = "sha256-1LsOt0+jF00EEDLALXZhrKpLTpoNINgh23OevK0KztM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-995toHrVVEZ/24ZgEWcgXwz0AFVPdXmylKiEimEBwNQ=";

  preCheck = ''
    HOME=$TMPDIR
  '';

  postInstall = ''
    installManPage man/man1/shadowenv.1
    installManPage man/man5/shadowlisp.5
    installShellCompletion --bash sh/completions/shadowenv.bash
    installShellCompletion --fish sh/completions/shadowenv.fish
    installShellCompletion --zsh sh/completions/_shadowenv
  '';

  meta = {
    description = "Reversible directory-local environment variable manipulations";
    homepage = "https://shopify.github.io/shadowenv/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "shadowenv";
  };
})
