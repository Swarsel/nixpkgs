{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  acres,
  attrs,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  importlib-resources,
  jinja2,
  looseversion,
  matplotlib,
  nibabel,
  nilearn,
  nipype,
  nitransforms,
  numpy,
  packaging,
  pandas,
  pybids,
  # tests
  pytest-cov-stub,
  pytest-env,
  pytestCheckHook,
  pyyaml,
  scikit-image,
  scipy,
  seaborn,
  svgutils,
  sysctl,
  templateflow,
  traits,
  transforms3d,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "niworkflows";
  version = "1.14.4";

  src = fetchFromGitHub {
    owner = "nipreps";
    repo = "niworkflows";
    tag = finalAttrs.version;
    hash = "sha256-AMUOiIL33kcJtlKT+L5QwcUh8mBBkf80uzOQZFKDauo=";
  };

  # fails to determine the version automatically
  env.SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-env
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Needed for tests that read the system memory usage on Darwin
    sysctl
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    acres
    attrs
    importlib-resources
    jinja2
    looseversion
    matplotlib
    nibabel
    nilearn
    nipype
    nitransforms
    numpy
    packaging
    pandas
    pybids
    pyyaml
    scikit-image
    scipy
    seaborn
    svgutils
    templateflow
    traits
    transforms3d
  ];

  disabledTestPaths = [
    "niworkflows/tests/test_registration.py"
  ];

  disabledTests = [
    # try to download data:
    "ROIsPlot"
    "ROIsPlot2"
    "niworkflows.interfaces.cifti._prepare_cifti"
    "niworkflows.utils.misc.get_template_specs"
    "test_GenerateCifti"
    "test_SimpleShowMaskRPT"
    "test_cifti_surfaces_plot"
    "test_brain_extraction_wf_smoketest"
  ];

  enabledTestPaths = [ "niworkflows" ];
  pyproject = true;
  pythonImportsCheck = [ "niworkflows" ];
  pythonRelaxDeps = [ "traits" ];

  meta = {
    description = "Common workflows for MRI (anatomical, functional, diffusion, etc.)";
    homepage = "https://github.com/nipreps/niworkflows";
    changelog = "https://github.com/nipreps/niworkflows/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "niworkflows-boldref";
  };
})
