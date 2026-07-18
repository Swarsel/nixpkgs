{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coloredlogs,
  executor,
  humanfriendly,
  naturalsort,
  property-manager,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "update-dotdee";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-update-dotdee";
    rev = finalAttrs.version;
    hash = "sha256-2k7FdgWM0ESHQb2za87yhXGaR/rbMYLVcv10QexUH1A=";
  };

  postPatch = ''
    substituteInPlace tox.ini \
      --replace-fail " --cov --showlocals --verbose" ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    coloredlogs
    executor
    humanfriendly
    naturalsort
    property-manager
    six
  ];

  disabledTests = [
    # TypeError: %o format: an integer is required, not str
    "test_executable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "update_dotdee" ];

  meta = {
    description = "Generic modularized configuration file manager";
    homepage = "https://github.com/xolox/python-update-dotdee";
    changelog = "https://github.com/xolox/python-update-dotdee/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
    mainProgram = "update-dotdee";
  };
})
