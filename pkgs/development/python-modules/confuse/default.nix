{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  # dependencies
  pyyaml,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "confuse";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "beetbox";
    repo = "confuse";
    rev = "v${version}";
    hash = "sha256-b3wwDa33fX0hkyact4v/ET0UN0PoOJ/PFaqyMRC7Q1Q=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    pyyaml
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "confuse" ];

  meta = {
    description = "Python configuration library for Python that uses YAML";
    homepage = "https://github.com/beetbox/confuse";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lovesegfault
      doronbehar
    ];
  };
}
