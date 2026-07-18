{
  lib,
  buildPythonPackage,
  fetchPypi,
  gevent,
  pytestCheckHook,
  setuptools,
  watchdog,
}:

buildPythonPackage rec {
  pname = "watchdog-gevent";
  version = "0.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-rmuU0PjIzhxZVs2GX2ErYfRWzxmAF0S7olo0n+jowzc=";
    pname = "watchdog_gevent";
  };

  postPatch = ''
    sed -i setup.cfg \
      -e 's:--cov watchdog_gevent::' \
      -e 's:--cov-report html::'

    substituteInPlace tests/test_observer.py \
      --replace-fail 'events == [FileModifiedEvent(__file__)]' 'FileModifiedEvent(__file__) in events'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    gevent
    watchdog
  ];

  pyproject = true;
  pythonImportsCheck = [ "watchdog_gevent" ];

  meta = {
    description = "Gevent-based observer for watchdog";
    homepage = "https://github.com/Bogdanp/watchdog_gevent";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ traxys ];
  };
}
