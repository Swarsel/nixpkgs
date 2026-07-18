{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  joblib,
  lxml,
  nibabel,
  numpy,
  numpydoc,
  packaging,
  pandas,
  pytest-timeout,
  pytestCheckHook,
  requests,
  scikit-learn,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "nilearn";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "nilearn";
    repo = "nilearn";
    tag = finalAttrs.version;
    hash = "sha256-AStjr+rQoUU4WjKbn+OgT+T+xQ3cTjkKxgF6jX3SX64=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail " --template=maint_tools/templates/index.html" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-timeout
    numpydoc
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    joblib
    lxml
    nibabel
    numpy
    pandas
    requests
    scikit-learn
    scipy
    packaging
  ];

  # do subset of tests which don't fetch resources
  enabledTestPaths = [ "nilearn/connectome/tests" ];
  pyproject = true;

  meta = {
    description = "Module for statistical learning on neuroimaging data";
    homepage = "https://nilearn.github.io";
    changelog = "https://github.com/nilearn/nilearn/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
