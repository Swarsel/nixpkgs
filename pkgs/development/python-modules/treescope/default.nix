{
  lib,
  fetchFromGitHub,
  # tests
  absl-py,
  buildPythonPackage,
  # build-system
  flit-core,
  # optional-dependencies
  ipython,
  jax,
  jaxlib,
  # dependencies
  numpy,
  omegaconf,
  palettable,
  pydantic,
  pytestCheckHook,
  torch,
}:

buildPythonPackage rec {
  pname = "treescope";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "google-deepmind";
    repo = "treescope";
    tag = "v${version}";
    hash = "sha256-SfycwuI/B7S/rKkaqxtnJI26q89313pvj/Xsomg6qyA=";
  };

  nativeCheckInputs = [
    absl-py
    jax
    jaxlib
    omegaconf
    pydantic
    pytestCheckHook
    torch
  ];

  build-system = [ flit-core ];
  dependencies = [ numpy ];

  optional-dependencies = {
    notebook = [
      ipython
      jax
      palettable
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "treescope" ];

  meta = {
    description = "Interactive HTML pretty-printer for machine learning research in IPython notebooks";
    homepage = "https://github.com/google-deepmind/treescope";
    changelog = "https://github.com/google-deepmind/treescope/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
