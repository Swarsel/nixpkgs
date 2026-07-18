{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  # optional-dependencies
  pandas,
  polars,
  pyarrow,
  # tests
  pytest-mock,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastexcel";
  version = "0.20.2";

  src = fetchFromGitHub {
    owner = "ToucanToco";
    repo = "fastexcel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lceUFw9+FsEoCWSNieCYGJW+pCqCpfthEAFCfXKdpj0=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  nativeCheckInputs = [
    pandas
    polars
    pyarrow
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf python/fastexcel
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-04jqysfab+mEir1f2kc15DCdueu1h+HS4FOIol4sBZY=";
  };

  optional-dependencies = {
    pandas = [
      pandas
      pyarrow
    ];

    polars = [
      polars
    ];

    pyarrow = [
      pyarrow
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "fastexcel"
    "fastexcel._fastexcel"
  ];

  meta = {
    description = "Fast excel file reader for Python, written in Rust";
    homepage = "https://github.com/ToucanToco/fastexcel/";
    changelog = "https://github.com/ToucanToco/fastexcel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
