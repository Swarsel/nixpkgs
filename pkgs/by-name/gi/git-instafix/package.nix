{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  libgit2,
  oniguruma,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-instafix";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "quodlibetor";
    repo = "git-instafix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uz+KQ8cQT3v97EtmbAv2II30dUrFD0hMo/GhnqcdBOs=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    oniguruma
  ];

  cargoHash = "sha256-B0XTk0KxA60AuaS6eO3zF/eA/cTcLwA31ipG4VjvO8Q=";
  env.RUSTONIG_SYSTEM_LIBONIG = true;
  nativeCheckInputs = [ gitMinimal ];

  meta = {
    description = "Quickly fix up an old commit using your currently-staged changes";
    homepage = "https://github.com/quodlibetor/git-instafix";
    changelog = "https://github.com/quodlibetor/git-instafix/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      mightyiam
      quodlibetor
    ];

    mainProgram = "git-instafix";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
