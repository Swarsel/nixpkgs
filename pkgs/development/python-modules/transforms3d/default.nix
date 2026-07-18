{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  sympy,
  versioneer,
}:

buildPythonPackage rec {
  pname = "transforms3d";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "matthew-brett";
    repo = "transforms3d";
    tag = version;
    hash = "sha256-9wICu7zNYF54e6xcDpZxqctB4GVu5Knf79Z36016Rpw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scipy
    sympy
  ];

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "transforms3d" ];

  meta = {
    description = "Convert between various geometric transformations";
    homepage = "https://matthew-brett.github.io/transforms3d";
    changelog = "https://github.com/matthew-brett/transforms3d/blob/main/Changelog";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
