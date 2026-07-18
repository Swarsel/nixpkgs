{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "conway-polynomials";
  version = "0.10";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-T2GfZPgaPrFsTibFooT+7sJ6b0qtZHZD55ryiYAa4PM=";
    pname = "conway_polynomials";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "conway_polynomials" ];

  meta = {
    description = "Python interface to Frank Lübeck's Conway polynomial database";
    homepage = "https://github.com/sagemath/conway-polynomials";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.sage ];
  };
})
