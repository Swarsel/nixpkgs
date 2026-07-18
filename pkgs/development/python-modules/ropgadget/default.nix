{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  capstone,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ropgadget";
  version = "7.7";

  src = fetchFromGitHub {
    owner = "JonathanSalwan";
    repo = "ROPgadget";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fKvXxz5SbrUynG/9pV6KMIxCVFU9l192oFJFB9HHBz0=";
  };

  # Test suite is working with binaries
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ capstone ];
  pyproject = true;
  pythonImportsCheck = [ "ropgadget" ];

  meta = {
    description = "Tool to search for gadgets in binaries to facilitate ROP exploitation";
    homepage = "http://shell-storm.org/project/ROPgadget/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bennofs ];
    mainProgram = "ROPgadget";
  };
})
