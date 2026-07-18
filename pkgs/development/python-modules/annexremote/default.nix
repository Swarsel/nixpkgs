{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "annexremote";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "Lykos153";
    repo = "AnnexRemote";
    tag = "v${version}";
    hash = "sha256-RShDcqAjG+ujGzWu5S9za24WSsIWctqi3nWQ8EU4DTo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "annexremote" ];

  meta = {
    description = "Helper module to easily develop git-annex remotes";
    homepage = "https://github.com/Lykos153/AnnexRemote";
    changelog = "https://github.com/Lykos153/AnnexRemote/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ montag451 ];
  };
}
