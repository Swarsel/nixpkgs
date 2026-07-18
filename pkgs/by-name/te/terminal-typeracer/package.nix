{
  lib,
  stdenv,
  fetchFromGitLab,
  libiconv,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "terminal-typeracer";
  version = "2.1.5";

  src = fetchFromGitLab {
    owner = "ttyperacer";
    repo = "terminal-typeracer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7LKpOO+PVGGtFJh1dZW/n/zovTxxZbb2VQwzgmjZhIY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-PECQ6KoHLPgUosC7gxniIoLHA5tWb0JfAUm93XFCcpk=";

  env = {
    LIBGIT2_NO_VENDOR = 0;
    OPENSSL_NO_VENDOR = 1;
  };

  meta = {
    description = "Open source terminal based version of Typeracer written in rust";
    homepage = "https://gitlab.com/ttyperacer/terminal-typeracer";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ yoctocell ];
    platforms = lib.platforms.unix;
    mainProgram = "typeracer";
  };
})
