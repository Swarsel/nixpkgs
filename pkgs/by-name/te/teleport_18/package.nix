{
  buildGo125Module,
  buildTeleport,
  wasm-bindgen-cli_0_2_122,
  extPatches ? [ ],
  withRdpClient ? true,
}:

buildTeleport {
  inherit withRdpClient extPatches;
  version = "18.9.2";
  cargoHash = "sha256-+B5fGIzCpiYmqVcM4iy+PTIdtvuvtufQiXMHNzHTDlQ=";
  vendorHash = "sha256-LJmpFHvFsBsneq1Cl3vvqxBGB94gSjaikNDZtQfwNjM=";
  buildGoModule = buildGo125Module;
  hash = "sha256-w6qCH57L2rwClbSpZeG01eekzj3JRNijwSdfl+wx8v8=";
  pnpmHash = "sha256-8tKVv5SPJlS89EsHhF8qpThkh4n47qRBbHDCgX17Cdg=";
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_122;
}
