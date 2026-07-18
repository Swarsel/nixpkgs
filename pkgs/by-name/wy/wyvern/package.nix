{
  lib,
  cmake,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wyvern";
  version = "1.4.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-OjL3wEoh4fT2nKqb7lMefP5B0vYyUaTRj09OXPEVfW4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-3zcXHl/CK5p/5BpGwafMYF/ztE6Erid9nS49vRFyPfE=";
  cargoPatches = [ ./cargo-lock.patch ];

  meta = {
    description = "Simple CLI client for installing and maintaining linux GOG games";
    homepage = "https://git.sr.ht/~nicohman/wyvern";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    platforms = lib.platforms.linux;
    mainProgram = "wyvern";
  };
})
