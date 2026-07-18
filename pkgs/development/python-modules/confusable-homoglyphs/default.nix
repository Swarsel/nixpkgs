{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

let
  libName = "confusable-homoglyphs";
  snakeLibName = builtins.replaceStrings [ "-" ] [ "_" ] libName;
in
buildPythonPackage rec {
  pname = libName;
  version = "3.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-uZUAHJsuG0zqDPXzhAp8eRiKjLutBT1pNXK9jBwexGA=";
    pname = snakeLibName;
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.cli;
  build-system = [ setuptools ];

  disabledTests = [
    "test_generate_categories" # touches network
    "test_generate_confusables" # touches network
  ];

  optional-dependencies = {
    cli = [ click ];
  };

  pyproject = true;
  pythonImportsCheck = [ snakeLibName ];

  meta =
    let
      inherit (lib) licenses maintainers;
    in
    {
      description = "Detect confusable usage of unicode homoglyphs, prevent homograph attacks";
      homepage = "https://sr.ht/~valhalla/confusable_homoglyphs/";
      changelog = "https://confusable-homoglyphs.readthedocs.io/en/latest/history.html";
      license = licenses.mit;
      maintainers = with maintainers; [ ajaxbits ];
    };
}
