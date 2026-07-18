{
  lib,
  buildPythonPackage,
  fastapi,
  fetchPypi,
  poetry-core,
  starlette,
}:

buildPythonPackage rec {
  pname = "imia";
  version = "0.5.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4CzevO7xgo8Hb1JHe/eGEtq/KCrJM0hV/7SRV2wmux8=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    starlette
    fastapi
  ];

  # running the real tests would require sqlalchemy 1.4 and starsessions 1.x
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "imia" ];

  meta = {
    description = "Authentication library for Starlette and FastAPI";
    homepage = "https://github.com/alex-oleshkevich/imia";
    changelog = "https://github.com/alex-oleshkevich/imia/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
