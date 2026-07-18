{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  textx,
}:

buildPythonPackage (finalAttrs: {
  pname = "strpdatetime";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "RhetTbull";
    repo = "strpdatetime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p/iLq+x+dRW2QPva/VEA9emtxb0k3hnL91l1itTsYSc=";
  };

  patches = [ ./fix-locale.patch ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ textx ];
  pyproject = true;
  pythonImportsCheck = [ "strpdatetime" ];
  pythonRelaxDeps = [ "textx" ];

  meta = {
    description = "Parse strings into Python datetime objects";
    homepage = "https://github.com/RhetTbull/strpdatetime";
    changelog = "https://github.com/RhetTbull/strpdatetime/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
