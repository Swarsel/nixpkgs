{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "ida-netnode";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "williballenthin";
    repo = "ida-netnode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hXApNeeDYHX41zuYDpSNqSXdM/c8DoVXuB6NMqYf7iU=";
  };

  # Module has no test and requires IDA to be installed
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  # pythonImportsCheck = [ "netnode"];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Humane API for storing and accessing persistent data in IDA Pro databases";
    homepage = "https://github.com/williballenthin/ida-netnode";
    changelog = "https://github.com/williballenthin/ida-netnode/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
