{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "zenoh";
  version = "1.9.0"; # nixpkgs-update: no auto update

  src = fetchFromGitHub {
    owner = "eclipse-zenoh";
    repo = "zenoh-python";
    rev = version;
    hash = "sha256-rKWbJti5bgwAfc8LpQFsU6KhhcWyWAwOX+SF1UAGRbk=";
  };

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src pname version;
    hash = "sha256-g7Om2QvlbwVmB0wGcbuafUELh53IJ2uM+miHyzBKQQI=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "zenoh"
  ];

  meta = {
    description = "Python API for zenoh";
    homepage = "https://github.com/eclipse-zenoh/zenoh-python";

    license = with lib.licenses; [
      asl20
      epl20
    ];

    maintainers = with lib.maintainers; [ markuskowa ];
  };
}
