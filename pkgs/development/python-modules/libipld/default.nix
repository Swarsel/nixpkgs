{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  maturin,
  nix-update-script,
  pytest-benchmark,
  pytest-codspeed,
  pytest-xdist,
  # nativeCheckInputs
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "libipld";
  version = "3.4.1";

  # use pypi, GitHub does not include Cargo.lock
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XTT8j5DJVDIPyn/vEg5f6a9Y+2dP9yNfJ4cDZN5sEG8=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
    pytest-codspeed
    pytest-xdist
  ];

  build-system = [
    maturin
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-8DYIiX/lFGYz/4+vWgoYTsV5L3O7rulof6UomrulbeM=";
  };

  disabledTests = [
    # touches network
    "test_decode_car"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "libipld" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast Python library to work with IPLD: DAG-CBOR, CID, CAR, multibase";
    homepage = "https://github.com/MarshalX/python-libipld";
    changelog = "https://github.com/MarshalX/python-libipld/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vji ];
  };
}
