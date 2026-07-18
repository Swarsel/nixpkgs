{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "opentypespec";
  version = "1.9.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5j89rMDKxGLLoN88/T7+e0xE8/eOmKN3eDpWxekJGiQ=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];

  meta = {
    description = "Python library for OpenType specification metadata";
    homepage = "https://github.com/simoncozens/opentypespec-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
