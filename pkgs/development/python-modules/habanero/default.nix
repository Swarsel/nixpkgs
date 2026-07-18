{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  httpx,
  pytestCheckHook,
  tqdm,
  urllib3,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "habanero";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "sckott";
    repo = "habanero";
    tag = "v${version}";
    hash = "sha256-XI+UOm3xONBNVSlywfBhnsCA9RdpEwDQ4oQixn4UBKk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
  ];

  build-system = [ hatchling ];

  dependencies = [
    httpx
    tqdm
    urllib3
  ];

  # almost the entirety of the test suite makes network calls
  enabledTestPaths = [ "test/test-filters.py" ];
  pyproject = true;
  pythonImportsCheck = [ "habanero" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Python interface to Library Genesis";
    homepage = "https://habanero.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nico202 ];
  };
}
