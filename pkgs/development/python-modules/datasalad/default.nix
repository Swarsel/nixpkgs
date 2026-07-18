{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitMinimal,
  hatch-vcs,
  hatchling,
  more-itertools,
  psutil,
  pytestCheckHook,
  unzip,
}:

buildPythonPackage rec {
  pname = "datasalad";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datasalad";
    tag = "v${version}";
    hash = "sha256-w00QY6oz0FgfgdY3f+mVRRnsOT0WJZV64ymgsXAINac=";
  };

  nativeCheckInputs = [
    gitMinimal
    pytestCheckHook
    more-itertools
    psutil
    unzip
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "datasalad" ];

  meta = {
    description = "Pure-Python library with a collection of utilities for working with Git and git-annex";
    homepage = "https://github.com/datalad/datasalad";
    changelog = "https://github.com/datalad/datasalad/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
