{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "alibuild";
  version = "1.17.31";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-agAWJaaaHGN2oQaaIkMNEeU712bkWXEPH3jP8oH5Qjs=";
  };

  nativeBuildInputs = with python3Packages; [ pip ];
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    requests
    pyyaml
    boto3
    jinja2
    distro
  ];

  pyproject = true;
  pythonRelaxDeps = [ "boto3" ];

  meta = {
    description = "Build tool for ALICE experiment software";
    homepage = "https://alisw.github.io/alibuild/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ktf ];
  };
})
