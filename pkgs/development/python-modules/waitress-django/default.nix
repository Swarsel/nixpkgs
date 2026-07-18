{
  lib,
  buildPythonPackage,
  django,
  setuptools,
  waitress,
}:

buildPythonPackage {
  pname = "waitress-django";
  version = "1.0.0";
  src = ./src;
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  pythonPath = [
    django
    waitress
  ];

  meta = {
    description = "Waitress WSGI server serving django";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ basvandijk ];
    mainProgram = "waitress-serve-django";
  };
}
