{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  click,
  click-default-group,
  docformatter,
  jinja2,
  # dependencies
  pydantic,
  pytestCheckHook,
  # build-system
  setuptools,
  toposort,
  xsdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "xsdata-pydantic";
  version = "24.5";

  src = fetchFromGitHub {
    owner = "tefra";
    repo = "xsdata-pydantic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ExgAXQRNfGQRSZdMuWc8ldJPqz+3c4Imgu75KXLXHNk=";
  };

  nativeCheckInputs = [
    click
    click-default-group
    docformatter
    jinja2
    pytestCheckHook
    toposort
  ];

  build-system = [ setuptools ];

  dependencies = [
    pydantic
    xsdata
  ];

  disabledTests = [
    # AssertionError: SystemExit(2) is not None
    "test_complete"
  ];

  pyproject = true;
  pythonImportsCheck = [ "xsdata_pydantic" ];

  meta = {
    description = "Naive XML & JSON Bindings for python pydantic classes";
    homepage = "https://github.com/tefra/xsdata-pydantic";
    changelog = "https://github.com/tefra/xsdata-pydantic/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ berrij ];
    platforms = lib.platforms.all;
  };
})
