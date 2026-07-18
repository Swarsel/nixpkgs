{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonschema,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "cvss";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "RedHatProductSecurity";
    repo = "cvss";
    tag = "v${version}";
    hash = "sha256-udUs76wfvC9LfjlKyWmuPV0RT2P/COTwYw3hgDt3tPs=";
  };

  nativeCheckInputs = [
    jsonschema
    unittestCheckHook
  ];

  preCheck = ''
    cd tests
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cvss" ];

  meta = {
    description = "Library for CVSS2/3/4";
    homepage = "https://github.com/RedHatProductSecurity/cvss";
    changelog = "https://github.com/RedHatProductSecurity/cvss/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cvss_calculator";
  };
}
