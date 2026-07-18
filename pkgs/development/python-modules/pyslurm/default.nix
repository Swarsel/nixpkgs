{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  setuptools,
  slurm,
}:

buildPythonPackage rec {
  pname = "pyslurm";
  version = "25.11.2";

  src = fetchFromGitHub {
    owner = "PySlurm";
    repo = "pyslurm";
    tag = "v${version}";
    hash = "sha256-hPAX2udntxpjibUK//Ec06EKNgUFU5AiBN15IZvgo3Q=";
  };

  nativeBuildInputs = [ setuptools ];

  buildInputs = [
    cython
    slurm
  ];

  env = {
    SLURM_INCLUDE_DIR = "${lib.getDev slurm}/include";
    SLURM_LIB_DIR = "${lib.getLib slurm}/lib";
  };

  # Test cases need /etc/slurm/slurm.conf and require a working slurm installation
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Python bindings to Slurm";
    homepage = "https://github.com/PySlurm/pyslurm";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
