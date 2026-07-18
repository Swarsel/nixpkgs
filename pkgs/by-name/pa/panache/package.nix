{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "panache";
  version = "2.61.0";

  src = fetchFromGitHub {
    owner = "jolars";
    repo = "panache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZHiebrY0a7tUx8e6rC/l91rqAyyj/2fasOIhGi4E7FI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-VL3ftML4GUNIqmY52N+Cr1sKmPFwCJp9s2eb1z5Au7o=";

  postInstall = ''
    installShellCompletion --cmd panache \
      --bash target/completions/panache.bash \
      --fish target/completions/panache.fish \
      --zsh target/completions/_panache

    installManPage target/man/*
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Language server, formatter, and linter for Pandoc, Quarto, and R Markdown";
    homepage = "https://github.com/jolars/panache";
    changelog = "https://github.com/jolars/panache/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jolars ];
    mainProgram = "panache";
  };
})
