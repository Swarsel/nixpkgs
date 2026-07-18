{
  lib,
  buildPythonPackage,
  fetchPypi,
  gcc,
  ipykernel,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jupyter-c-kernel";
  version = "1.2.2";

  src = fetchPypi {
    inherit version;
    sha256 = "e4b34235b42761cfc3ff08386675b2362e5a97fb926c135eee782661db08a140";
    pname = "jupyter_c_kernel";
  };

  postPatch = ''
    substituteInPlace jupyter_c_kernel/kernel.py \
      --replace-fail "'gcc'" "'${gcc}/bin/gcc'"
  '';

  # no tests in repository
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ ipykernel ];
  pyproject = true;

  meta = {
    description = "Minimalistic C kernel for Jupyter";
    homepage = "https://github.com/brendanrius/jupyter-c-kernel/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "install_c_kernel";
  };
}
