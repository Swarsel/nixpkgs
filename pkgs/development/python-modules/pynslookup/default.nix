{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynslookup";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "wesinator";
    repo = "pynslookup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GdI5Jg/+HjdtbzpLa28z/ZUGPJL9vEbJ+Jd4HP4pQCY=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ dnspython ];
  pyproject = true;
  pythonImportsCheck = [ "nslookup" ];

  meta = {
    description = "Module to do DNS lookups";
    homepage = "https://github.com/wesinator/pynslookup";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
