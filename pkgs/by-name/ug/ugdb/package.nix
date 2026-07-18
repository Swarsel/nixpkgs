{
  lib,
  fetchFromGitHub,
  oniguruma,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ugdb";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "ftilde";
    repo = "ugdb";
    tag = finalAttrs.version;
    hash = "sha256-6mlvr/2hqwu5Zoo9E2EfOmyg0yEGBi4jk3BsRZ+zkN8=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ oniguruma ];
  cargoHash = "sha256-+J4gwjQXB905yk4b2GwpamXO/bHpwqMxw6GsnusbJKU=";
  env.RUSTONIG_SYSTEM_LIBONIG = 1;
  # Upstream has a failing test :<
  doCheck = false;

  meta = with lib; {
    description = "Alternative TUI for gdb";
    homepage = "https://github.com/ftilde/ugdb";
    changelog = "https://github.com/ftilde/ugdb/blob/master/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ maintainers.justdeeevin ];
    platforms = platforms.unix;
    mainProgram = "ugdb";
  };
})
