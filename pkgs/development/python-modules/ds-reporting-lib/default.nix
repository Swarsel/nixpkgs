{
  lib,
  buildPythonPackage,
  dep-scan,

  # build
  setuptools,
}:

buildPythonPackage rec {
  inherit (dep-scan) version src;
  pname = "ds-reporting-lib";
  # no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "reporting_lib" ];
  sourceRoot = "${src.name}/packages/reporting-lib";

  meta = {
    inherit (dep-scan.meta)
      homepage
      license
      maintainers
      teams
      ;

    description = "Reporting library for owasp depscan";
  };
}
