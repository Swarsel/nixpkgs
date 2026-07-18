{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  # dependencies
  msgpack,
  # testing
  pydantic,
  pytestCheckHook,
  python-dateutil,
  pytz,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "ormsgpack";
  version = "1.12.2";

  src = fetchFromGitHub {
    owner = "aviramha";
    repo = "ormsgpack";
    tag = version;
    hash = "sha256-a2PgCCIPPJt6YNW7UFl9urYZkAoVj5Np0lbv4QfzMAs=";
  };

  # requires nightly features (feature(portable_simd))
  env.RUSTC_BOOTSTRAP = true;

  nativeCheckInputs = [
    pytestCheckHook
    pydantic
    python-dateutil
    pytz
  ];

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-PLLSVoQLsbTOIMqOsaaei/dm8SybfyqP0WLJW8hTOoo=";
  };

  dependencies = [
    msgpack
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ormsgpack"
  ];

  meta = {
    description = "Fast msgpack serialization library for Python derived from orjson";
    homepage = "https://github.com/aviramha/ormsgpack";
    changelog = "https://github.com/aviramha/ormsgpack/releases/tag/${version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ sarahec ];
  };
}
