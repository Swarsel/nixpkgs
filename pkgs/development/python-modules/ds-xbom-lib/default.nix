{
  lib,
  buildPythonPackage,
  dep-scan,

  # build
  setuptools,
}:

buildPythonPackage rec {
  inherit (dep-scan) version src;
  pname = "ds-xbom-lib";
  # no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "xbom_lib" ];
  sourceRoot = "${src.name}/packages/xbom-lib";

  meta = {
    inherit (dep-scan.meta)
      homepage
      license
      maintainers
      teams
      ;

    description = "xBOM library for owasp depscan";
  };
}
