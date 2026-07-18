{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lstr";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "bgreenwell";
    repo = "lstr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lJ6BSvlJiyZUOoz0QuahIgZ6GZ9NDcmvvQ7MEd9c/7U=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ (lib.getDev openssl) ];
  cargoHash = "sha256-pRPcJwdhrQ+P70zaiuPCAI53lW+zEulqSrK5w8SCraQ=";
  nativeCheckInputs = [ gitMinimal ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Fast, minimalist directory tree viewer written in Rust";
    homepage = "https://github.com/bgreenwell/lstr";
    changelog = "https://github.com/bgreenwell/lstr/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      DieracDelta
      philiptaron
    ];

    mainProgram = "lstr";
  };
})
