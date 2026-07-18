{
  lib,
  fetchFromGitHub,
  bokeh,
  buildPythonPackage,
  ipython,
  matplotlib,
  nbconvert,
  nbformat,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "livelossplot";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "stared";
    repo = "livelossplot";
    tag = "v${version}";
    hash = "sha256-qC1FBFJyf2IlDIffJ5Xs89WcN/GFA/8maODhc1u2xhA=";
  };

  nativeCheckInputs = [
    ipython
    nbconvert
    nbformat
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bokeh
    matplotlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "livelossplot" ];

  meta = {
    description = "Live training loss plot in Jupyter for Keras, PyTorch, and others";
    homepage = "https://github.com/stared/livelossplot";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
