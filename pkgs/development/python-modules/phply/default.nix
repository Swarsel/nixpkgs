{
  lib,
  buildPythonPackage,
  fetchPypi,
  ply,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "phply";
  version = "1.2.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Cyd3TShfUHo0RYBaBfj7KZj1bXCScPeLiSCLZbDYSRc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];
  dependencies = [ ply ];
  pyproject = true;
  pythonImportsCheck = [ "phply" ];

  meta = {
    description = "Lexer and parser for PHP source implemented using PLY";
    homepage = "https://github.com/viraptor/phply";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
