{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-mock,
  pytestCheckHook,
  twine,
}:

buildPythonPackage (finalAttrs: {
  pname = "hatch-jupyter-builder";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = "hatch-jupyter-builder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QDWHVdjtexUNGRL+dVehdBwahSW2HmNkZKkQyuOghyI=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
    twine
  ];

  build-system = [ hatchling ];
  dependencies = [ hatchling ];

  disabledTests = [
    # tests pip install, which unsurprisingly fails
    "test_hatch_build"
  ];

  pyproject = true;

  meta = {
    description = "Hatch plugin to help build Jupyter packages";
    homepage = "https://github.com/jupyterlab/hatch-jupyter-builder";
    changelog = "https://github.com/jupyterlab/hatch-jupyter-builder/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "hatch-jupyter-builder";
  };
})
