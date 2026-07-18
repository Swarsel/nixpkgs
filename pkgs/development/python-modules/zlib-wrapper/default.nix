{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zlib-wrapper";
  version = "0.1.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Yxqc7fSDdnAPlGLzTbgcEQxiTKJDSJmPgm0eV62JiGQ=";
    pname = "zlib_wrapper";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zlib_wrapper" ];

  meta = {
    description = "Wrapper around zlib with custom header crc32";
    homepage = "https://pypi.org/project/zlib_wrapper/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
