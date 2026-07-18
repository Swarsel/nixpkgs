{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  # build-system
  hatchling,
  # dependencies
  importlib-resources,
  iso3166,
  pycountry,
  # optional-dependencies
  pydantic,
  # tests
  pytestCheckHook,
  pythonOlder,
  rstr,
}:

buildPythonPackage rec {
  pname = "schwifty";
  version = "2026.07.1";

  src = fetchPypi {
    inherit pname;
    hash = "sha256-Rux0m5MQG5aBrEiQAEjalxdbabYWAU33qFSuN+rddEA=";
    # The version is different missing leading zeros in the CalVer month.
    # This is due to PyPI's normalization of integers
    version = "2026.7.1";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    iso3166
    pycountry
    rstr
  ]
  ++ lib.optionals (pythonOlder "3.12") [ importlib-resources ];

  optional-dependencies = {
    pydantic = [ pydantic ];
  };

  pyproject = true;
  pythonImportsCheck = [ "schwifty" ];

  meta = {
    description = "Validate/generate IBANs and BICs";
    homepage = "https://github.com/mdomke/schwifty";
    changelog = "https://github.com/mdomke/schwifty/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ milibopp ];
  };
}
