{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  distutils,
  fickling,
  intervaltree,
  json5,
  pytestCheckHook,
  pyyaml,
  scipy,
  setuptools,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "graphtage";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "graphtage";
    tag = "v${version}";
    hash = "sha256-Bz2T8tVdVOdXt23yPITkDNL46Y5LZPhY3SXZ5bF3CHw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    distutils
    setuptools
  ];

  dependencies = [
    colorama
    fickling
    intervaltree
    json5
    pyyaml
    scipy
    tqdm
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "graphtage" ];
  pythonRelaxDeps = [ "json5" ];

  meta = {
    description = "Utility to diff tree-like files such as JSON and XML";
    homepage = "https://github.com/trailofbits/graphtage";
    changelog = "https://github.com/trailofbits/graphtage/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ veehaitch ];
    mainProgram = "graphtage";
  };
}
