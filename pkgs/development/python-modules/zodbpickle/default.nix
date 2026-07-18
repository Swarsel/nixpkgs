{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zodbpickle";
  version = "4.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-efM8xJoJsoqLO0A2nBQhboBXF364x+iY12r9azGUy3g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    mv src/zodbpickle/tests ./.
    rm -rf src
  '';

  build-system = [ setuptools ];

  # fails..
  disabledTests = [
    "test_dump"
    "test_dumps"
    "test_load"
    "test_loads"
  ];

  pyproject = true;
  pythonImportsCheck = [ "zodbpickle" ];

  meta = {
    description = "Fork of Python's pickle module to work with ZODB";
    homepage = "https://github.com/zopefoundation/zodbpickle";
    changelog = "https://github.com/zopefoundation/zodbpickle/blob/${version}/CHANGES.rst";

    license = with lib.licenses; [
      psfl
      zpl21
    ];

    maintainers = [ ];
  };
}
