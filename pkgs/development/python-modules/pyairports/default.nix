{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyairports";
  version = "2.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-PWCnJ/zk2oG5xjk+qK4LM9Z7N+zjRN/8hj90njrWK80=";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyairports" ];

  meta = {
    description = "Package which enables airport lookup by 3-letter IATA code";
    homepage = "https://github.com/ozeliger/pyairports";
    license = lib.licenses.asl20;
  };
})
