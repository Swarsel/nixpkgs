{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coloredlogs,
  humanfriendly,
  pytest-cov-stub,
  pytestCheckHook,
  verboselogs,
}:

buildPythonPackage rec {
  pname = "property-manager";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-property-manager";
    rev = version;
    sha256 = "1v7hjm7qxpgk92i477fjhpcnjgp072xgr8jrgmbrxfbsv4cvl486";
  };

  propagatedBuildInputs = [
    coloredlogs
    humanfriendly
    verboselogs
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  format = "setuptools";

  meta = {
    description = "Useful property variants for Python programming";
    homepage = "https://github.com/xolox/python-property-manager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
  };
}
