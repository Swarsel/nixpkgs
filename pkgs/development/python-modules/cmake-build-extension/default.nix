{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  gitpython,
  ninja,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "cmake-build-extension";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "diegoferigo";
    repo = "cmake-build-extension";
    tag = "v${version}";
    hash = "sha256-taAwxa7Sv+xc8xJRnNM6V7WPcL+TWZOkngwuqjAslzc=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cmake
    ninja
    gitpython
  ];

  doPythonRuntimeDepsCheck = false;
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "cmake_build_extension" ];

  meta = {
    description = "Setuptools extension to build and package CMake projects";
    homepage = "https://github.com/diegoferigo/cmake-build-extension";
    changelog = "https://github.com/diegoferigo/cmake-build-extension/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ scoder12 ];
  };
}
