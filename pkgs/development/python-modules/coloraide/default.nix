{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  typing-extensions,
}:
let
  version = "8.8.1";
in
buildPythonPackage {
  inherit version;
  pname = "coloraide";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = "coloraide";
    tag = version;
    hash = "sha256-a6FAMtvJMKkMfJVNjlxb7ayIPVZwsGYktO9bkRJjmL4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "coloraide"
  ];

  meta = {
    description = "Library to aid in using colors";
    homepage = "https://github.com/facelessuser/coloraide";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers._9999years
      lib.maintainers.djacu
    ];
  };
}
