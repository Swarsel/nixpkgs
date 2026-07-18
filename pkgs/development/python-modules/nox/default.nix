{
  lib,
  fetchFromGitHub,
  argcomplete,
  # dependencies
  attrs,
  buildPythonPackage,
  colorlog,
  dependency-groups,
  # build-system
  hatchling,
  humanize,
  jinja2,
  packaging,
  # tests
  pytestCheckHook,
  tomli,
  # passthru
  tox,
  uv,
  virtualenv,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "nox";
  version = "2026.07.11";

  src = fetchFromGitHub {
    owner = "wntrblm";
    repo = "nox";
    tag = finalAttrs.version;
    hash = "sha256-Ve9mKZ6C9X/SjscEIO11fyMqokjlYZqbqXWC1R1+Kmc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ hatchling ];

  dependencies = [
    argcomplete
    attrs
    colorlog
    dependency-groups
    humanize
    packaging
    virtualenv
  ];

  disabledTestPaths = [
    # AttributeError: module 'tox.config' has...
    "tests/test_tox_to_nox.py"
  ];

  disabledTests = [
    # Assertion errors
    "test_uv"
    # Test requires network access
    "test_noxfile_script_mode_url_req"
    # Don't test CLi mode
    "test_noxfile_script_mode"
  ];

  optional-dependencies = {
    tox-to-nox = [
      jinja2
      tox
    ];

    uv = [ uv ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nox" ];

  meta = {
    description = "Flexible test automation for Python";
    homepage = "https://nox.thea.codes/";
    changelog = "https://github.com/wntrblm/nox/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      doronbehar
      fab
    ];
  };
})
