{
  lib,
  fetchPypi,
  python,
}:

python.pkgs.buildPythonPackage rec {
  pname = "memory-profiler";
  version = "0.61.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Tltz14ZKHRKS+3agPoKj5475NNBoKKaY2dradtogZ7A=";
    pname = "memory_profiler";
  };

  propagatedBuildInputs = with python.pkgs; [
    psutil # needed to profile child processes
    matplotlib # needed for plotting memory usage
  ];

  format = "setuptools";

  meta = {
    description = "Module for monitoring memory usage of a process";

    longDescription = ''
      This is a python module for monitoring memory consumption of a process as
      well as line-by-line analysis of memory consumption for python programs.
    '';

    homepage = "https://pypi.org/project/memory_profiler/";
    license = lib.licenses.bsd3;
    mainProgram = "mprof";
  };
}
