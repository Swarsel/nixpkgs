{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fetchpatch,
  ply,
  setuptools,
  six,
  tornado,
}:

buildPythonPackage rec {
  pname = "thriftpy2";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Thriftpy";
    repo = "thriftpy2";
    tag = "v${version}";
    hash = "sha256-idUKqpyRj8lq9Aq6vEEeYEawzRPOdNsySnkgfhwPtMc=";
  };

  patches = [
    (fetchpatch {
      sha256 = "sha256-UBcbd8NTkPyko1s9jTjKlQ7HprwtyOZS0m66u1CPH3A=";
      url = "https://github.com/Thriftpy/thriftpy2/commit/0127d259eb4b96acb060cd158ca709f0597b148c.patch";
    })
  ];

  nativeBuildInputs = [ cython ];
  # Not all needed files seems to be present
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ply
    six
    tornado
  ];

  pyproject = true;
  pythonImportsCheck = [ "thriftpy2" ];

  meta = {
    description = "Python module for Apache Thrift";
    homepage = "https://github.com/Thriftpy/thriftpy2";
    changelog = "https://github.com/Thriftpy/thriftpy2/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
