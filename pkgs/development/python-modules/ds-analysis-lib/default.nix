{
  lib,
  # deps
  appthreat-vulnerability-db,
  buildPythonPackage,
  custom-json-diff,
  cvss,
  dep-scan,
  pytest-cov-stub,
  pytestCheckHook,
  rich,
  # build
  setuptools,
  toml,
  # test
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  inherit (dep-scan) version src;
  pname = "ds-analysis-lib";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    appthreat-vulnerability-db
    custom-json-diff
    cvss
    rich
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "analysis_lib" ];
  sourceRoot = "${src.name}/packages/analysis-lib";

  meta = {
    inherit (dep-scan.meta)
      homepage
      license
      maintainers
      teams
      ;

    description = "Analysis library for owasp depscan";
  };
}
