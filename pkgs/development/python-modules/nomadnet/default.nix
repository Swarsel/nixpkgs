{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxmf,
  msgpack,
  qrcode,
  rns,
  setuptools,
  urwid,
}:

buildPythonPackage (finalAttrs: {
  pname = "nomadnet";
  version = "1.2.7";

  src = fetchPypi {
    inherit (finalAttrs) version pname;
    hash = "sha256-52pFpgeRBXouASwpx8vLn+ZDHx7Tl6NttkgRkENhT1s=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    rns
    lxmf
    msgpack
    urwid
    qrcode
  ];

  pyproject = true;
  pythonImportsCheck = [ "nomadnet" ];

  meta = {
    description = "Off-grid, resilient mesh communication";
    homepage = "https://github.com/markqvist/NomadNet";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      drupol
      fab
    ];

    mainProgram = "nomadnet";
  };
})
