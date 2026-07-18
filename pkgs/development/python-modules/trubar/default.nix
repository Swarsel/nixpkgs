{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  libcst,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "trubar";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "janezd";
    repo = "trubar";
    tag = version;
    hash = "sha256-ChKmeACEMnFcMYSdkdVlFiE3td171ihUS2A+qsP5ASk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    libcst
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "trubar" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Utility for translation of strings and f-strings in Python files";
    homepage = "https://github.com/janezd/trubar";
    changelog = "https://github.com/janezd/trubar/releases/tag/${version}";
    license = [ lib.licenses.mit ];
    maintainers = [ ];
  };
}
