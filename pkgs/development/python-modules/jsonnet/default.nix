{
  buildPythonPackage,
  pkgs,
  setuptools,
}:

buildPythonPackage {
  inherit (pkgs.jsonnet) pname version src;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "_jsonnet" ];

  meta = {
    inherit (pkgs.jsonnet.meta)
      description
      maintainers
      license
      homepage
      ;
  };
}
