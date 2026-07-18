{
  lib,
  aiovban,
  buildPythonPackage,
  pyaudio,
  setproctitle,
  setuptools,
  uvloop,
}:

buildPythonPackage (finalAttrs: {
  inherit (aiovban) version pyproject src;
  pname = "aiovban-pyaudio";
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiovban
    pyaudio
  ];

  optional-dependencies = {
    cli = [
      setproctitle
      uvloop
    ];
  };

  pythonImportsCheck = [
    "aiovban_pyaudio"
  ];

  sourceRoot = "${aiovban.src.name}/aiovban_pyaudio";

  meta = {
    inherit (aiovban.meta) maintainers;
    description = "PyAudio wrapper for aiovban";
    homepage = "https://github.com/wmbest2/aiovban/tree/main/aiovban_pyaudio";
    changelog = "https://github.com/wmbest2/aiovban/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
