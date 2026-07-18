{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  fetchPypi,
  libiconv,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "pdoc-pyo3-sample-library";
  version = "1.0.11";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ZGMo7WgymkSDQu8tc4rTfWNsIWO0AlDPG0OzpKRq3oA=";
    pname = "pdoc_pyo3_sample_library";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  # no tests
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-XqXkheK8OEzlLEbq09KMRFxrjJBnFaxvj4rIL2gmydA=";
  };

  pyproject = true;
  pythonImportsCheck = [ "pdoc_pyo3_sample_library" ];

  meta = {
    description = "Sample PyO3 library used in pdoc tests";
    homepage = "https://github.com/mitmproxy/pdoc-pyo3-sample-library";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pbsds ];
  };
})
