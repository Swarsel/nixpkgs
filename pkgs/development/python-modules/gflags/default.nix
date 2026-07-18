{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  six,
}:

buildPythonPackage rec {
  pname = "python-gflags";
  version = "3.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "40ae131e899ef68e9e14aa53ca063839c34f6a168afe622217b5b875492a1ee2";
  };

  propagatedBuildInputs = [ six ];
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    # clashes with our pythhon wrapper (which is in argv0)
    # AssertionError: 'gflags._helpers_test' != 'nix_run_setup.py'
    py.test -k 'not testGetCallingModule'
  '';

  format = "setuptools";

  meta = {
    description = "Module for command line handling, similar to Google's gflags for C++";
    homepage = "https://github.com/google/python-gflags";
    license = lib.licenses.bsd3;
  };
}
