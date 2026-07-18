{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "asahi-nvram";
  version = "0.2.4";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-wRlKTMzckygRkZoAT3ZDYnAF3owWEziAGNl4jteCf+A=";
  };

  cargoHash = "sha256-Syc4QgKUJM37FW3JQqVNN9WEMFwCSoo/BaI55k2HFRY=";
  cargoDepsName = finalAttrs.pname;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to read and write nvram variables on ARM Macs";
    homepage = "https://crates.io/crates/asahi-nvram";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lukaslihotzki ];
    platforms = lib.platforms.linux;
    mainProgram = "asahi-nvram";
  };
})
