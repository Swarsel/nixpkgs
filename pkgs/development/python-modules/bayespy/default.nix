{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  h5py,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  truncnorm,
}:

buildPythonPackage rec {
  pname = "bayespy";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "bayespy";
    repo = "bayespy";
    tag = version;
    hash = "sha256-kx87XY4GCL1PQIeZyovEbrPyCC/EVA6Hdvt+3P/D6VI=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-Tk3z94+vbGaSIqGFFRQZz0pcXI1Fzcbnva3oWnv502U=";
      url = "https://salsa.debian.org/python-team/packages/python-bayespy/-/raw/071f54815608b31aebac8f8e83bc532b2c632a48/debian/patches/numpy2.4-compat.patch";
    })
  ];

  postPatch = ''
    substituteInPlace versioneer.py \
      --replace-fail SafeConfigParser ConfigParser \
      --replace-fail readfp read_file
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    h5py
    truncnorm
  ];

  pyproject = true;
  pythonImportsCheck = [ "bayespy" ];

  meta = {
    description = "Variational Bayesian inference tools for Python";
    homepage = "http://www.bayespy.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
