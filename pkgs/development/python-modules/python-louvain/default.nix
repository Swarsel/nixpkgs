{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  networkx,
  numpy,
  pandas,
  scipy,
}:

buildPythonPackage rec {
  pname = "python-louvain";
  version = "0.16";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-t7ot9QAv0o0+54mklTK6rRH+ZI5PIRfPB5jnUgodpWs=";
  };

  patches = [
    # Fix test_karate
    (fetchpatch {
      hash = "sha256-9oJ9YvKl2sI8oGhfyauNS+HT4kXsDt0L8S2owluWdj0=";
      name = "fix-karate-test-networkx-2.7.patch";
      url = "https://github.com/taynaud/python-louvain/pull/95/commits/c95d767e72f580cb15319fe08d72d87c9976640b.patch";
    })
  ];

  propagatedBuildInputs = [
    networkx
    numpy
  ];

  nativeCheckInputs = [
    pandas
    scipy
  ];

  format = "setuptools";
  pythonImportsCheck = [ "community" ];

  meta = {
    description = "Louvain Community Detection";
    homepage = "https://github.com/taynaud/python-louvain";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "community";
  };
}
