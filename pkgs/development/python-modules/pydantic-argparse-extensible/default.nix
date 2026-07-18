{
  lib,
  buildPythonPackage,
  fetchPypi,
  nix-update-script,
  poetry-core,
  pydantic,
}:

buildPythonPackage rec {
  pname = "pydantic-argparse-extensible";
  version = "1.3.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DLE2eFrofCDcEPrn5g/mZlxNidVXThUumWV+u+yyvOI=";
    pname = "pydantic_argparse_extensible";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    pydantic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pydantic_argparse_extensible"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Typed wrapper around argparse using pydantic models";
    homepage = "https://pypi.org/project/pydantic-argparse-extensible";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers._9999years ];
  };
}
