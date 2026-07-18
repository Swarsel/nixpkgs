{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lowfi";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "talwat";
    repo = "lowfi";
    tag = finalAttrs.version;
    hash = "sha256-/GU1e01AjeS4AVBvQUi/GZKeQ0X+hnmt+kyW3gp0jgg=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  cargoHash = "sha256-iuC0YBhzK8mATJekTgBDMiXATRdThem35p5AyDXQNGo=";

  checkFlags = [
    # Skip this test as it doesn't work in the nix sandbox
    "--skip=tests::tracks::list::download"
  ];

  buildFeatures = [ "scrape" ] ++ lib.optionals stdenv.hostPlatform.isLinux [ "mpris" ];

  meta = {
    description = "Extremely simple lofi player";
    homepage = "https://github.com/talwat/lowfi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zsenai ];
    mainProgram = "lowfi";
  };
})
