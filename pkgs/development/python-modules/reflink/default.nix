{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "reflink";
  version = "0.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iCN17nMZJ1rl9qahKHQGNl2sHpZDuRrRDlGH0/hCU70=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pytest-runner" ""
  '';

  propagatedBuildInputs = [ cffi ];
  # FIXME: These do not work, and I have been unable to figure out why.
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  propagatedNativeBuildInputs = [ cffi ];
  pythonImportsCheck = [ "reflink" ];

  meta = {
    description = "Python reflink wraps around platform specific reflink implementations";
    homepage = "https://gitlab.com/rubdos/pyreflink";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}
