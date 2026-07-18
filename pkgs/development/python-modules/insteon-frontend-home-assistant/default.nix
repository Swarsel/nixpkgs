{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "insteon-frontend-home-assistant";
  version = "0.6.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-p5hL8LE8h/4ytHft/v23uzv7YwR9UBDVru8n7WeY99Q=";
    pname = "insteon_frontend_home_assistant";
  };

  nativeBuildInputs = [ setuptools ];
  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "insteon_frontend" ];

  meta = {
    description = "Insteon frontend for Home Assistant";
    homepage = "https://github.com/pyinsteon/insteon-panel";
    changelog = "https://github.com/pyinsteon/insteon-panel/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
