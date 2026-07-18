{
  lib,
  buildPythonPackage,
  colorlog,
  docstring-parser,
  fetchPypi,
  isodate,
  pytestCheckHook,
  requests,
  setuptools,
  websocket-client,
}:

buildPythonPackage (finalAttrs: {
  pname = "chat-downloader";
  version = "0.2.8";

  src = fetchPypi {
    inherit (finalAttrs) version pname;
    hash = "sha256-WBasBhefgRkOdMdz2K/agvS+cY6m3/33wiu+Jl4d1Cg=";
  };

  # Tests try to access the network.
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    requests
    isodate
    docstring-parser
    colorlog
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "chat_downloader" ];

  meta = {
    description = "Simple tool used to retrieve chat messages from livestreams, videos, clips and past broadcasts";
    homepage = "https://github.com/xenova/chat-downloader";
    changelog = "https://github.com/xenova/chat-downloader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "chat_downloader";
  };
})
