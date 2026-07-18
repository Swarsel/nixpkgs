{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyudev,
  setuptools,
}:

buildPythonPackage rec {
  pname = "monitorcontrol";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "newAM";
    repo = "monitorcontrol";
    tag = version;
    hash = "sha256-KyVLNZLpzmxABQQiHGniCcND7DwZwpT4gJC+sJihoag=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyudev ];
  pyproject = true;
  pythonImportsCheck = [ pname ];

  meta = {
    description = "Python monitor controls using DDC-CI";
    homepage = "https://github.com/newAM/monitorcontrol";
    changelog = "https://github.com/newAM/monitorcontrol/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ newam ];
    platforms = lib.platforms.linux;
    mainProgram = "monitorcontrol";
  };
}
