{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "sharedmem";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "rainwoodman";
    repo = "sharedmem";
    tag = finalAttrs.version;
    hash = "sha256-sQYSIMLXhChBDKlb8x7kRo1ZKKXEdWSjvxp0SZGKems=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "sharedmem" ];

  meta = {
    description = "Easier parallel programming on shared memory computers";
    homepage = "http://rainwoodman.github.io/sharedmem/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ edwtjo ];
  };
})
