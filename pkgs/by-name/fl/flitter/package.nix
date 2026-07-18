{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flitter";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "alexozer";
    repo = "flitter";
    tag = finalAttrs.version;
    hash = "sha256-aXTQeUKhwa2uVipKIs8n0XBiWa5o7U6UMlAUlnzXyzE=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
  ];

  cargoHash = "sha256-SOmq1txYMJGUVkkrE3kWmioaJzBX9raZ+ExFlPYGDM8=";

  meta = {
    description = "Livesplit-inspired speedrunning split timer for Linux/macOS terminal";
    homepage = "https://github.com/alexozer/flitter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.unix;
    mainProgram = "flitter";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
