{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  # datasets:
  anndata,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  pooch,
  # settings:
  pydantic-settings,
  # tests
  pytestCheckHook,
  python-dotenv,
  pyyaml,
  # dependencies
  session-info2,
  # sphinx:
  sphinx,
  tqdm,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "scverse-misc";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "scverse";
    repo = "scverse-misc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PkvOaxGbZ1i10xgghdvGLCKiXcwg/eZzYvQ7Gp3K+JE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    session-info2
    typing-extensions
  ];

  optional-dependencies = {
    datasets = [
      anndata
      pooch
      pyyaml
      tqdm
    ];

    settings = [
      pydantic-settings
      python-dotenv
    ];

    spatialdata = [
      # spatialdata (unpackaged)
    ];

    sphinx = [
      # pydocstring-rs (unpackaged)
      sphinx
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "scverse_misc" ];

  meta = {
    description = "Miscellaneous utility code used by scverse packages";
    homepage = "https://github.com/scverse/scverse-misc";
    changelog = "https://github.com/scverse/scverse-misc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
