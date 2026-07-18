{
  lib,
  buildPythonPackage,
  cflow,
  fetchPypi,
  graphviz,
  networkx,
  pydot,
  which,
}:

buildPythonPackage rec {
  pname = "pycflow2dot";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1zm8x2pd0q6zza0fw7hg9g1qvybfnjq6ql9b8mh2fc45l7l25655";
  };

  propagatedBuildInputs = [
    cflow
    graphviz
    pydot
    networkx
    which
  ];

  checkPhase = ''
    cd tests
    export PATH=$out/bin:$PATH
    make all
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pycflow2dot" ];

  meta = {
    description = "Layout C call graphs from cflow using GraphViz dot";
    homepage = "https://github.com/johnyf/pycflow2dot";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "cflow2dot";
  };
}
