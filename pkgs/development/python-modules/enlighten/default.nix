{
  lib,
  # dependencies
  blessed,
  buildPythonPackage,
  fetchPypi,
  prefixed,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "enlighten";
  version = "1.14.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hcNUEqmk84hrMzfUH4E0Qfq5ow2fW18MAVvQeKRBFHM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  dependencies = [
    blessed
    prefixed
  ];

  format = "setuptools";
  pythonImportsCheck = [ "enlighten" ];

  meta = {
    description = "Enlighten Progress Bar for Python Console Apps";
    homepage = "https://github.com/Rockhopper-Technologies/enlighten";
    changelog = "https://github.com/Rockhopper-Technologies/enlighten/releases/tag/${version}";
    license = with lib.licenses; [ mpl20 ];

    maintainers = with lib.maintainers; [
      veprbl
      doronbehar
    ];
  };
}
