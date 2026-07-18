{
  buildGoModule,
  buildTeleport,
  wasm-bindgen-cli_0_2_95,
  extPatches ? [ ],
  withRdpClient ? true,
}:

buildTeleport {
  inherit buildGoModule withRdpClient extPatches;
  version = "17.7.25";
  cargoHash = "sha256-BE/TBZoOaB3Th14E+t3qJ+0Uww56TtRA1sRQ+usFo+Y=";
  vendorHash = "sha256-ERwCdWdp230wkqsRUCnd1hbO4PqXo+gDPsoGbxQqt04=";
  hash = "sha256-IrelrkTvOBcTkO7cHf572MU5KkOQq3we53dgFsDCSRo=";
  pnpmHash = "sha256-TARwHswSWbKk2eoyynuaOm7pvt2CwbjtklqnM+9/YXM=";
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_95;
}
