{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  langcodes,
  pgpy-dtc,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
  setuptools,
  validators,
}:

buildPythonPackage rec {
  pname = "sectxt";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "DigitalTrustCenter";
    repo = "sectxt";
    tag = version;
    hash = "sha256-x8HcERUZpOijTEXbbtnG0Co5PiQlO4v5bxKM4CAExnI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    python-dateutil
    langcodes
    pgpy-dtc
    validators
  ];

  pyproject = true;
  pythonImportsCheck = [ "sectxt" ];

  meta = {
    description = "Security.txt parser and validator";
    homepage = "https://github.com/DigitalTrustCenter/sectxt";
    changelog = "https://github.com/DigitalTrustCenter/sectxt/releases/tag/${src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ networkexception ];
  };
}
