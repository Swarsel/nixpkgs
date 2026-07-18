{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  configobj,
  pytestCheckHook,
  pyyaml,
  setuptools,
  setuptools-scm,
  sphinx,
}:

buildPythonPackage rec {
  pname = "everett";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "willkg";
    repo = "everett";
    tag = "v${version}";
    hash = "sha256-5cjPV2pt2x8RmaGWTRWeX3Nb1QeDd7245FZ0tEmYCSk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sphinx
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    configobj
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "everett" ];

  meta = {
    description = "Python configuration library for your app";
    homepage = "https://github.com/willkg/everett";
    changelog = "https://github.com/willkg/everett/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ jherland ];
  };
}
