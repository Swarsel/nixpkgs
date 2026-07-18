{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pyahocorasick,
  pytest-benchmark,
  pytestCheckHook,
  pythonOlder,
  rustPlatform,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "ahocorasick-rs";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-V503Bwp8Idqc2ZiLn7RxKXJztgy0EmWG1tzZn6r8XKU=";
    pname = "ahocorasick_rs";
  };

  nativeBuildInputs = with rustPlatform; [
    maturinBuildHook
    cargoSetupHook
  ];

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
    pyahocorasick
    hypothesis
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-RfgjO0qffiAZynQ/xChd81L8S0sqTGdWvpHPrz3bKlQ=";
  };

  dependencies = lib.optionals (pythonOlder "3.12") [ typing-extensions ];
  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "ahocorasick_rs" ];

  meta = {
    description = "Fast Aho-Corasick algorithm for Python";
    homepage = "https://github.com/G-Research/ahocorasick_rs/";
    changelog = "https://github.com/G-Research/ahocorasick_rs/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
