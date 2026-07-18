{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  flit-core,
  ifaddr,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "yeelight";
  version = "0.7.16";

  src = fetchFromGitLab {
    owner = "stavros";
    repo = "python-yeelight";
    tag = "v${version}";
    hash = "sha256-WLEXTDVcSpGCmfEI31cQXGf9+4EIUCkcaeaj25f4ERU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ ifaddr ];
  enabledTestPaths = [ "yeelight/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "yeelight" ];

  meta = {
    description = "Python library for controlling YeeLight RGB bulbs";
    homepage = "https://gitlab.com/stavros/python-yeelight/";
    changelog = "https://gitlab.com/stavros/python-yeelight/-/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
