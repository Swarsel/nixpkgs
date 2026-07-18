{
  lib,
  dbus,
  fetchCrate,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "asahi-btsync";
  version = "0.2.5";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-lAfbr2D6dITdlFCbz++OVz2SxYGapiZtrNjeBruBDJ8=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-80B47vRUgb+QWYoxqPWk1gCdWFM5bIxq0tR5FpssRQ4=";
  cargoDepsName = finalAttrs.pname;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to sync Bluetooth pairing keys with macos on ARM Macs";
    homepage = "https://crates.io/crates/asahi-btsync";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lukaslihotzki ];
    platforms = lib.platforms.linux;
    mainProgram = "asahi-btsync";
  };
})
