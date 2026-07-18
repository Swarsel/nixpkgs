{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  gmsh,
  matplotlib,
  mpi4py,
  numpy,
  openssh,
  pyamg,
  python,
  pythonAtLeast,
  scikit-fmm,
  scipy,
  tkinter,
}:

buildPythonPackage rec {
  pname = "fipy";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "usnistgov";
    repo = "fipy";
    tag = version;
    hash = "sha256-pq5Xjp3YD5cILfV+Atl/Sq0SeZjDR/QQa4/F59LhGIo=";
  };

  propagatedBuildInputs = [
    numpy
    scipy
    pyamg
    matplotlib
    tkinter
    mpi4py
    future
    scikit-fmm
    openssh
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ gmsh ];

  # NOTE: Two of the doctests in fipy.matrices.scipyMatrix._ScipyMatrix.CSR fail, and there is no
  # clean way to disable them.
  doCheck = false;
  nativeCheckInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ gmsh ];

  checkPhase = ''
    export OMPI_MCA_plm_rsh_agent=${openssh}/bin/ssh
    ${python.interpreter} setup.py test --modules
  '';

  # Python 3.12 is not yet supported.
  # https://github.com/usnistgov/fipy/issues/997
  # https://github.com/usnistgov/fipy/pull/1023
  disabled = pythonAtLeast "3.12";
  format = "setuptools";

  # NOTE: Importing fipy within the sandbox will fail because plm_rsh_agent isn't set and the process isn't able
  # to start a daemon on the builder.
  # pythonImportsCheck = [ "fipy" ];
  meta = {
    description = "Finite Volume PDE Solver Using Python";
    homepage = "https://www.ctcms.nist.gov/fipy/";
    changelog = "https://github.com/usnistgov/fipy/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ wd15 ];
  };
}
