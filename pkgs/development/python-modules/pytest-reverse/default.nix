{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-reverse";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "pytest-reverse";
    tag = version;
    hash = "sha256-d9wx4N3RnPbOk+dZuJaCdbtXfQQwjGo5MwVNrNVGtlo=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_reverse" ];

  meta = {
    description = "Pytest plugin to reverse test order";
    homepage = "https://github.com/adamchainz/pytest-reverse";
    changelog = "https://github.com/adamchainz/pytest-reverse/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
