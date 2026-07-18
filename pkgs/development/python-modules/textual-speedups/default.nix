{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "textual-speedups";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "willmcgugan";
    repo = "textual-speedups";
    tag = "v${version}";
    hash = "sha256-zsDA8qPpeiOlmL18p4pItEgXQjgrQEBVRJazrGJT9Bw=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # No tests
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-Bz4ocEziOlOX4z5F9EDry99YofeGyxL/6OTIf/WEgK4=";
  };

  pyproject = true;
  pythonImportsCheck = [ "textual_speedups" ];

  meta = {
    description = "Optional Rust speedups for Textual";
    homepage = "https://github.com/willmcgugan/textual-speedups";
    # No license (yet?)
    # https://github.com/willmcgugan/textual-speedups/issues/2
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
