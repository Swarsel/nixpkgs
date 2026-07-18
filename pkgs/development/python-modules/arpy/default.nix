{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "arpy";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "arpy";
    tag = finalAttrs.version;
    hash = "sha256-jD1XJJhcpJymn0CwZ65U06xLKm1JjHffmx/umEO7a5s=";
  };

  checkInputs = [ unittestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "arpy" ];

  meta = {
    description = "Library for accessing the archive files and reading the contents";
    homepage = "https://github.com/viraptor/arpy";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thornycrackers ];
  };
})
