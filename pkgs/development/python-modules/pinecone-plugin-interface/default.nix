{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "pinecone-plugin-interface";
  version = "0.0.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-uOZnXkGEczOqE5I8xE2qP4VnbXFXMkaC3BZAWIqYKEY=";
    pname = "pinecone_plugin_interface";
  };

  build-system = [
    poetry-core
  ];

  pyproject = true;

  meta = {
    description = "Plugin interface for the Pinecone python client";
    homepage = "https://www.pinecone.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
  };
}
