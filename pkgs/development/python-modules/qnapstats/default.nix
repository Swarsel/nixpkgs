{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  requests,
  responses,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "qnapstats";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "colinodell";
    repo = "python-qnapstats";
    tag = version;
    hash = "sha256-4zGCMwuPL9QFVLgyZ6/aV9YBQJBomPkX34C7ULEd4Fw=";
  };

  # File "/build/source/tests/test-models.py", line 124, in <module>
  #   assert json.dumps(qnap.get_system_stats(), sort_keys=True) == systemstats
  # https://github.com/colinodell/python-qnapstats/issues/104
  doCheck = false;
  nativeCheckInputs = [ responses ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} tests/test-models.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    requests
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "qnapstats" ];

  meta = {
    description = "Python API for obtaining QNAP NAS system stats";
    homepage = "https://github.com/colinodell/python-qnapstats";
    changelog = "https://github.com/colinodell/python-qnapstats/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
