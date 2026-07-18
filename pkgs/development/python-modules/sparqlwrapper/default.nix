{
  lib,
  buildPythonPackage,
  fetchPypi,
  keepalive,
}:

buildPythonPackage rec {
  pname = "sparqlwrapper";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-P+0+vMd2F6SnTSZEuG/Yjg8y5/cAOseyszTAJiAXMfE=";
    pname = "SPARQLWrapper";
  };

  propagatedBuildInputs = [ keepalive ];
  # Doesn't actually run tests
  doCheck = false;
  format = "setuptools";

  # break circular dependency loop
  patchPhase = ''
    sed -i '/rdflib/d' setup.cfg
  '';

  meta = {
    description = "This is a wrapper around a SPARQL service. It helps in creating the query URI and, possibly, convert the result into a more manageable format";
    homepage = "http://rdflib.github.io/sparqlwrapper";
    license = lib.licenses.w3c;
    mainProgram = "rqw";
  };
}
