{
  lib,
  fetchFromGitHub,
  libloragw-2g4,
  libloragw-sx1301,
  libloragw-sx1302,
  nix-update-script,
  protobuf,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "chirpstack-concentratord";
  version = "4.7.1";

  src = fetchFromGitHub {
    owner = "chirpstack";
    repo = "chirpstack-concentratord";
    rev = "v${finalAttrs.version}";
    hash = "sha256-icvbZjqsDf/RLiDUyx0lQKRVHFh6FNxkLVkv9kckDBc=";
  };

  nativeBuildInputs = [
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libloragw-2g4
    libloragw-sx1301
    libloragw-sx1302
  ];

  cargoHash = "sha256-iJhNaXv5a8+9TZJGLdKZdq1VFE09w0L/05V1y6kabN0=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Concentrator HAL daemon for LoRa gateways";
    homepage = "https://www.chirpstack.io/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stv0g ];
    platforms = lib.platforms.linux;
    mainProgram = "chirpstack-concentratord";
  };
})
