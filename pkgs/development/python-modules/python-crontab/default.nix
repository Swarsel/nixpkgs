{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  python-dateutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-crontab";
  version = "3.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AHyK7mjd3z4E7E3OD6wSS5O9aL50cPyV0qlhehXeKRs=";
    pname = "python_crontab";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ python-dateutil ];

  disabledTests = [
    "test_07_non_posix_shell"
    # doctest that assumes /tmp is writeable, awkward to patch
    "test_03_usage"
    # Test is assuming $CURRENT_YEAR is not a leap year
    "test_19_frequency_at_month"
    "test_20_frequency_at_year"
  ];

  pyproject = true;
  pythonImportsCheck = [ "crontab" ];

  meta = {
    description = "Python API for crontab";

    longDescription = ''
      Crontab module for reading and writing crontab files
      and accessing the system cron automatically and simply using a direct API.
    '';

    homepage = "https://gitlab.com/doctormo/python-crontab/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ kfollesdal ];
  };
}
