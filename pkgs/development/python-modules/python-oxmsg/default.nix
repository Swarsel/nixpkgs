{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  olefile,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "python-oxmsg";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "scanny";
    repo = "python-oxmsg";
    tag = "v${version}";
    hash = "sha256-ramM27+SylBeJyb3kkRm1xn3qAefiLuBOvI/iucK2wM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    olefile
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "oxmsg" ];

  meta = {
    description = "Extract attachments from Outlook .msg files";
    homepage = "https://github.com/scanny/python-oxmsg";
    changelog = "https://github.com/scanny/python-oxmsg/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "oxmsg";
  };
}
