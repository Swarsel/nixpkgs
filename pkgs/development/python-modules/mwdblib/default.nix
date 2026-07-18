{
  lib,
  fetchFromGitHub,
  beautifultable,
  buildPythonPackage,
  click,
  click-default-group,
  humanize,
  keyring,
  requests,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mwdblib";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "mwdblib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eP8q5G97vfe7eN3+/+UF7Qda5/xzwC/GRrTorucjEGo=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beautifultable
    click
    click-default-group
    humanize
    keyring
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mwdblib" ];

  meta = {
    description = "Python client library for the mwdb service";
    homepage = "https://github.com/CERT-Polska/mwdblib";
    changelog = "https://github.com/CERT-Polska/mwdblib/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "mwdb";
  };
})
