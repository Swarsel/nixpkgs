{
  lib,
  buildPythonPackage,
  doit,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydevtool";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JeO6Tz0zzKwz7iuXdZlYSNSemzGLehRkd/tdUveG/Io=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ doit ];
  pyproject = true;
  pythonImportsCheck = [ "pydevtool" ];

  meta = {
    description = "CLI dev tools powered by pydoit";
    homepage = "https://github.com/pydoit/pydevtool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
