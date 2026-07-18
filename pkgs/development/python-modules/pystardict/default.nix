{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "pystardict";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "lig";
    repo = "pystardict";
    tag = "v${version}";
    hash = "sha256-VWOxggAKifN5f6nSN1xsSbg0hpKzrHDw+UqnAOzsXj0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "pystardict" ];

  meta = {
    description = "Library for manipulating StarDict dictionaries from within Python";
    homepage = "https://github.com/lig/pystardict";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ thornycrackers ];
  };
}
