{
  lib,
  buildPythonPackage,
  fetchPypi,
  pymeta3,
  python,
}:
buildPythonPackage rec {
  pname = "pybars3";
  version = "0.9.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ashH6QXlO5xbk2rxEskQR14nv3Z/efRSjBb5rx7A4lI=";
  };

  propagatedBuildInputs = [ pymeta3 ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests.py
    runHook postCheck
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pybars" ];

  meta = {
    description = "Handlebars.js template support for Python 3 and 2";
    homepage = "https://github.com/wbond/pybars3";
    changelog = "https://github.com/wbond/pybars3/releases/tag/${version}";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      jfly
      matusf
    ];
  };
}
