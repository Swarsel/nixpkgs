{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytest-benchmark,
  pytestCheckHook,
  rustPlatform,
}:
let
  pname = "fastcrc";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "overcat";
    repo = "fastcrc";
    tag = "v${version}";
    hash = "sha256-Q1R0EgxrfCMn/DxblOAW4Z7YOxpaZPL5Sx8SL/dry98=";
  };
in
buildPythonPackage {
  inherit pname version src;

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
  ];

  # Python source files interfere with testing
  preCheck = ''
    rm -r fastcrc
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-dWxQuWV3w1UM8yvLG/9SrJQxSSyWTXV0FWFDKjIHBf0=";
  };

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "fastcrc" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hyper-fast Python module for computing CRC(8, 16, 32, 64) checksum";
    homepage = "https://fastcrc.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pluiedev ];
  };
}
