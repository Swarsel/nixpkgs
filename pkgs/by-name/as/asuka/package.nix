{
  lib,
  fetchFromSourcehut,
  ncurses,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "asuka";
  version = "0.8.5";

  src = fetchFromSourcehut {
    owner = "~julienxx";
    repo = "asuka";
    tag = finalAttrs.version;
    hash = "sha256-+rj6P3ejc4Qb/uqbf3N9MqyqDT7yg9JFE0yfW/uzd6M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ncurses
    openssl
  ];

  cargoHash = "sha256-aNHkhcvOdK6sf6nWxCNPxcktYhrnmLdMrLqWb/1QBQ4=";

  meta = {
    description = "Gemini Project client written in Rust with NCurses";
    homepage = "https://git.sr.ht/~julienxx/asuka";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "asuka";
  };
})
