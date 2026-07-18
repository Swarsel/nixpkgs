{
  cargo,
  corrosion,
  hidapi,
  mkKdeDerivation,
  pkg-config,
  qtwebengine,
  rustPlatform,
  rustc,
  sources,
}:
mkKdeDerivation rec {
  inherit (sources.${pname}) version;
  pname = "kdeplasma-addons";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version cargoRoot;
    src = sources.${pname};
    hash = "sha256-2gtz9D05VloEKkQGF9/0fuMrFUtp2NpE/mcEd7D3Gkc=";
  };

  cargoRoot = "kdeds/kameleon/qmk/kameleon-qmk-helper";

  extraBuildInputs = [
    corrosion
    qtwebengine
    hidapi
  ];

  extraNativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustc
    cargo
    pkg-config
  ];
}
