{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyexcel,
  pyexcel-io,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  xlrd,
  xlwt,
}:

buildPythonPackage rec {
  pname = "pyexcel-xls";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "pyexcel";
    repo = "pyexcel-xls";
    tag = "v${version}";
    hash = "sha256-+iwdMSGUsUbWFO4s4+3Zf+47J9bzFffWthZoeThT8f0=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace "xlrd<2" "xlrd<3"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pyexcel
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyexcel-io
    xlrd
    xlwt
  ];

  pyproject = true;

  meta = {
    description = "Wrapper library to read, manipulate and write data in xls using xlrd and xlwt";
    homepage = "http://docs.pyexcel.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
