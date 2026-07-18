{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  rustPlatform,
  rustc,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "gb-io";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "althonos";
    repo = "gb-io.py";
    rev = "v${version}";
    hash = "sha256-6owaHSOVahgOG1gvN4Tox8c49qGzQ4lG1n8GKwEnCRk=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ rustPlatform.maturinBuildHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-ZUvcbVwhV2P8AvsuVoaPWUW5G9VaEvx3mt4kub0xHRk=";
  };

  pyproject = true;
  pythonImportsCheck = [ "gb_io" ];
  sourceRoot = src.name;

  meta = {
    description = "Python interface to gb-io, a fast GenBank parser written in Rust";
    homepage = "https://github.com/althonos/gb-io.py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dlesl ];
  };
}
