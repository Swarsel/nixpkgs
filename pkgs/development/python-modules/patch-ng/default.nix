{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "patch-ng";
  version = "1.19.0"; # note: `conan` package may require a hardcoded one

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-J0hHkvSsHBX+Lz5M7PdLuYM9M7dccVtx0Zn34efR94Y=";
  };

  format = "setuptools";

  meta = {
    description = "Library to parse and apply unified diffs";
    homepage = "https://github.com/conan-io/python-patch";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
