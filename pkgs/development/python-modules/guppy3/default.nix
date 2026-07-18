{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  tkinter,
}:

buildPythonPackage rec {
  pname = "guppy3";
  version = "3.1.7";

  src = fetchFromGitHub {
    owner = "zhuyifei1999";
    repo = "guppy3";
    tag = "v${version}";
    hash = "sha256-/vu47Mzi4q1g6JOoM01j/V1SDNMSJlP/ohuip5t+GtE=";
  };

  # Tests are starting a Tkinter GUI
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ tkinter ];
  pyproject = true;
  pythonImportsCheck = [ "guppy" ];

  meta = {
    description = "Python Programming Environment & Heap analysis toolset";
    homepage = "https://zhuyifei1999.github.io/guppy3/";
    changelog = "https://github.com/zhuyifei1999/guppy3/blob/${src.tag}/ChangeLog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
