{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  pyocd,
  pyocd-pemicro,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  spsdk,
  # passthru
  spsdk-pyocd,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "spsdk-pyocd";
  version = "0.3.4";

  # Latest tag missing on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-jvzXu6z9oo2oGoiDgCWWcU3yX/PuWm56MJzIcMWCgTM=";
    pname = "spsdk_pyocd";
  };

  # Cyclic dependency with spsdk
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    spsdk
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pyocd
  ];

  optional-dependencies = {
    pemicro = [
      pyocd-pemicro
    ];
  };

  pyproject = true;

  pythonRelaxDeps = [
    "pyocd"
  ];

  passthru.tests = {
    pytest = spsdk-pyocd.overridePythonAttrs {
      doCheck = true;
      pythonImportsCheck = [ "spsdk_pyocd" ];
    };
  };

  meta = {
    description = "Debugger probe plugin for SPSDK";
    homepage = "https://pypi.org/project/spsdk-pyocd";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
