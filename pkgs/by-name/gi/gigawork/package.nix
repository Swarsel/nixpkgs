{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gigawork";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "sgl-umons";
    repo = "gigawork";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CBm3YW3DODui5tAVIOqYhuijrAVo4+H2jLz/u/BGVlc=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    click
    gitpython
    jsonschema
    ruamel-yaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gigawork"
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "An automated tool for extracting GitHub Actions' workflows from Git repositories written in Python";
    homepage = "https://github.com/sgl-umons/gigawork";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "gigawork";
  };
})
