{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  libiconv,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "nlpo3";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "PyThaiNLP";
    repo = "nlpo3";
    tag = "nlpo3-python-v${version}";
    hash = "sha256-GQwUKc6VXF1mDzvB2HBwHlaC0Eu3sZvlTuGe0CDrP4k=";
  };

  postPatch = ''
    substituteInPlace tests/test_tokenize.py \
      --replace-fail "data/test_dict.txt" "$src/nlpo3-python/tests/data/test_dict.txt"
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ unittestCheckHook ];

  preCheck = ''
    rm -r nlpo3
  '';

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src sourceRoot;
    hash = "sha256-Kp2FL6GXb5g5jqvFWZxZUy7OuGaavN9DZkp9kdI4d/4=";
  };

  pyproject = true;
  pythonImportsCheck = [ "nlpo3" ];
  sourceRoot = "${src.name}/nlpo3-python";

  unittestFlagsArray = [
    "-s"
    "tests"
    "-v"
  ];

  meta = {
    description = "Thai Natural Language Processing library in Rust, with Python and Node bindings";
    homepage = "https://github.com/PyThaiNLP/nlpo3";
    changelog = "https://github.com/PyThaiNLP/nlpo3/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
