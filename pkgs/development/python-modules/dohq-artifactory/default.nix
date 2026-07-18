{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pyjwt,
  pytestCheckHook,
  python-dateutil,
  pythonAtLeast,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dohq-artifactory";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "devopshq";
    repo = "artifactory";
    tag = version;
    hash = "sha256-oGv7sZWi/e9WWa5W82pJ6d8S2d2e9gaoGZ3P/97IWoI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    python-dateutil
    pyjwt
  ];

  # https://github.com/devopshq/artifactory/issues/470
  disabled = pythonAtLeast "3.13";
  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;
  pythonImportsCheck = [ "artifactory" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python interface library for JFrog Artifactory";
    homepage = "https://devopshq.github.io/artifactory/";
    changelog = "https://github.com/devopshq/artifactory/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ h7x4 ];
  };
}
