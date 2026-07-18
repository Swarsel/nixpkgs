{
  lib,
  buildPythonPackage,
  click,
  commoncode,
  fetchPypi,
  pluggy,
  pytest-xdist,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "plugincode";
  version = "32.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QTLZOxdVJxxuImydouIET/YuvLhztelY1mqN3enzRfo=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    click
    commoncode
    pluggy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  # wants to read /etc/os-release and crashes because that is not available in the sandbox
  # pythonImportsCheck = [ "plugincode" ];
  disabledTests = [
    # We don't want black as an input
    "test_skeleton_codestyle"
  ];

  dontConfigure = true;
  format = "setuptools";

  meta = {
    description = "Library that provides plugin functionality for ScanCode toolkit";
    homepage = "https://github.com/nexB/plugincode";
    changelog = "https://github.com/nexB/plugincode/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
