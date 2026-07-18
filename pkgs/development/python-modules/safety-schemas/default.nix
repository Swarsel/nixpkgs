{
  lib,
  buildPythonPackage,
  dparse,
  fetchPypi,
  hatchling,
  packaging,
  pydantic,
  ruamel-yaml,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "safety-schemas";
  version = "0.0.18";

  src = fetchPypi {
    inherit version;
    hash = "sha256-OhJ6U7ruCoglMGtdG+SGZmks+YuqzpeF0Xv2BOkGSUo=";
    pname = "safety_schemas";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace hatchling==1.26.3 hatchling
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    dparse
    packaging
    pydantic
    ruamel-yaml
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "safety_schemas" ];

  pythonRelaxDeps = [
    "pydantic"
  ];

  meta = {
    description = "Schemas for Safety CLI";
    homepage = "https://pypi.org/project/safety-schemas/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
