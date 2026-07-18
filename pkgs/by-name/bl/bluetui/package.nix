{
  lib,
  fetchFromGitHub,
  dbus,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bluetui";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "pythops";
    repo = "bluetui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K+QAU9/XdGZonsKjBXbPbpJhWIHyaqxP6eb670n81LU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  cargoHash = "sha256-i77j7hKtVxDDiHEBz5E7iwGXWYg0f/NfwFnN71QfgPU=";

  meta = {
    description = "TUI for managing bluetooth on Linux";
    homepage = "https://github.com/pythops/bluetui";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      donovanglover
      matthiasbeyer
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bluetui";
  };
})
