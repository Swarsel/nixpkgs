{
  lib,
  # deps
  appthreat-vulnerability-db,
  buildPythonPackage,
  custom-json-diff,
  dep-scan,
  ds-analysis-lib,
  # test
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  quart,
  rich,
  # build
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  inherit (dep-scan) version src;
  pname = "ds-server-lib";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    pytest-cov-stub
    pytest-asyncio
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    appthreat-vulnerability-db
    custom-json-diff
    ds-analysis-lib
    quart
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "server_lib" ];
  sourceRoot = "${src.name}/packages/server-lib";

  meta = {
    inherit (dep-scan.meta)
      homepage
      license
      maintainers
      teams
      ;

    description = "Server library for owasp depscan";
  };
}
