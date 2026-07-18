{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "srgn";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "alexpovel";
    repo = "srgn";
    rev = "srgn-v${finalAttrs.version}";
    hash = "sha256-K9pHtsPD3Ab0I68y+QjHhzQwYBIQoJ0rc/fRomBDzVg=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-jgxA8T7Q7QXw7J53SDHpLEv2mFtgv89uGrbKlxzmhJQ=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash zsh fish; do
      installShellCompletion --cmd srgn "--$shell" <("$out/bin/srgn" --completions "$shell")
    done
  '';

  meta = {
    description = "Code surgeon for precise text and code transplantation";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ magistau ];
    mainProgram = "srgn";
    downloadPage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/${finalAttrs.src.rev}";
  };
})
