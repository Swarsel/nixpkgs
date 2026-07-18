{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  impacket,
  netaddr,
  poetry-core,
  pypykatz,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "lsassy";
  version = "3.1.16";

  src = fetchFromGitHub {
    owner = "Hackndo";
    repo = "lsassy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lPbZnoR6qWfVBSRAbTJsKpjBieidNsYgAXI3CXHEt1w=";
  };

  # Tests require an active domain controller
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    impacket
    netaddr
    pypykatz
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "lsassy" ];

  pythonRelaxDeps = [
    "impacket"
    "netaddr"
    "rich"
  ];

  meta = {
    description = "Python module to extract data from Local Security Authority Subsystem Service (LSASS)";
    homepage = "https://github.com/Hackndo/lsassy";
    changelog = "https://github.com/Hackndo/lsassy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "lsassy";
  };
})
