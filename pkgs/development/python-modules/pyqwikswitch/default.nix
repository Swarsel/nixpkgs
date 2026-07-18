{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyqwikswitch";
  version = "0.94";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-IpyWz+3EMr0I+xULBJJhBgdnQHNPJIM1SqKFLpszhQc=";
  };

  patches = [
    # https://github.com/kellerza/pyqwikswitch/pull/7
    (fetchpatch {
      hash = "sha256-sdO5jzIgKdneNY5dTngIzUFtyRg7HBGaZA1BBeAJxu4=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/kellerza/pyqwikswitch/commit/7b3f2211962b30bb6beea9a4fe17cd04cdf8e27f.patch";
    })
  ];

  doCheck = false; # no tests in sdist
  build-system = [ setuptools ];

  dependencies = [
    attrs
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyqwikswitch"
    "pyqwikswitch.threaded"
  ];

  meta = {
    description = "QwikSwitch USB Modem API binding for Python";
    homepage = "https://github.com/kellerza/pyqwikswitch";
    license = lib.licenses.mit;
    teams = [ lib.teams.home-assistant ];
  };
})
