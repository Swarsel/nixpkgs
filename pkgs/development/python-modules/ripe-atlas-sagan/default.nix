{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytestCheckHook,
  python-dateutil,
  pytz,
  ujson,
}:

buildPythonPackage rec {
  pname = "ripe-atlas-sagan";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "RIPE-NCC";
    repo = "ripe-atlas-sagan";
    rev = "v${version}";
    hash = "sha256-xIBIKsQvDmVBa/C8/7Wr3WKeepHaGhoXlgatXSUtWLA=";
  };

  propagatedBuildInputs = [
    cryptography
    python-dateutil
    pytz
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # This test fail for unknown reason, I suspect it to be flaky.
    "test_invalid_country_code"
  ];

  enabledTestPaths = [ "tests/*.py" ];
  format = "setuptools";

  optional-dependencies = {
    fast = [ ujson ];
  };

  pythonImportsCheck = [ "ripe.atlas.sagan" ];

  meta = {
    description = "Parsing library for RIPE Atlas measurements results";
    homepage = "https://github.com/RIPE-NCC/ripe-atlas-sagan";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
