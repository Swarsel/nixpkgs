{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "pinecone-plugin-assistant";
  version = "3.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-U/VI7eYKldef9I14ZaPQr9Zlztnnd1gnLmK6DGxjvSY=";
    pname = "pinecone_plugin_assistant";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "packaging"
  ];

  meta = {
    description = "Assistant plugin for Pinecone SDK";
    homepage = "https://www.pinecone.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.unix;
  };
}
