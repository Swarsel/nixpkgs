{
  alpaka,
  cargo,
  corrosion,
  discount,
  mkKdeDerivation,
  pkg-config,
  rustPlatform,
  rustc,
  sources,
}:
mkKdeDerivation rec {
  inherit (sources.${pname}) version;
  pname = "kdepim-addons";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version cargoRoot;
    src = sources.${pname};
    hash = "sha256-t62ThhOFWIqk+tgq+0ERSni2at+c1/9VHG88if6xG7A=";
  };

  cargoRoot = "plugins/webengineurlinterceptor/adblock";

  extraBuildInputs = [
    discount
    corrosion
    alpaka
  ];

  extraNativeBuildInputs = [
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];
}
