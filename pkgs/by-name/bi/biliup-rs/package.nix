{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "biliup-rs";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "biliup";
    repo = "biliup-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zbl/d0LXwxHWyzfcLg+AMJrLXlXOf+aIzdNYHEvAd90=";
  };

  nativeBuildInputs = [
    python3
    sqlite
  ];

  cargoHash = "sha256-bSnc8xFFcWONFX35G3S75ppqA2WF/M0EB/68BR1AgWM=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool for uploading videos to Bilibili";
    homepage = "https://biliup.github.io/biliup-rs";
    changelog = "https://github.com/biliup/biliup-rs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "biliup";
  };
})
