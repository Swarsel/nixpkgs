{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "chess-tui";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "thomas-mauran";
    repo = "chess-tui";
    tag = finalAttrs.version;
    hash = "sha256-B6CpUha5e2W82HnWOxV2arHAiqJCyL5bwkhELYQPxMg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ]
  # alsa-lib is required for the alsa-sys. alsa-lib does not compile on darwin
  ++ lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ]
  # bindgenHook is required for coreaudio-sys on darwin
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ rustPlatform.bindgenHook ];

  cargoHash = "sha256-Vik4FceQSYnziDpAqz7r7gpabUp2JL5u40iT0r8fnAw=";
  env.PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  checkFlags = [
    # assertion failed: result.is_ok()
    "--skip=tests::test_config_create"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Chess TUI implementation in rust";
    homepage = "https://github.com/thomas-mauran/chess-tui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ByteSudoer ];
    mainProgram = "chess-tui";
  };
})
