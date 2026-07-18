{
  lib,
  buildPythonPackage,
  future,
  psutil,
  pytest,
  pytest-fixture-config,
  pytest-shutil,
  requests,
  retry,
  setuptools,
  six,
}:

buildPythonPackage {
  inherit (pytest-fixture-config) version src patches;
  pname = "pytest-server-fixtures";

  postPatch = ''
    cd pytest-server-fixtures
  '';

  buildInputs = [ pytest ];
  # Don't run integration tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    future
    psutil
    pytest-shutil
    pytest-fixture-config
    requests
    retry
    six
  ];

  pyproject = true;

  meta = {
    description = "Extensible server fixures for py.test";
    homepage = "https://github.com/manahl/pytest-plugins";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
