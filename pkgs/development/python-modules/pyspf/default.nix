{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py3dns,
}:

buildPythonPackage rec {
  pname = "pyspf";
  version = "2.0.14";

  src = fetchFromGitHub {
    owner = "sdgathman";
    repo = "pyspf";
    rev = "pyspf-${version}";
    sha256 = "0bmimlmwrq9glnjc4i6pwch30n3y5wyqmkjfyayxqxkfrixqwydi";
  };

  propagatedBuildInputs = [ py3dns ];
  # requires /etc/resolv.conf to exist
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python API for Sendmail Milters (SPF)";
    homepage = "http://bmsi.com/python/milter.html";
    license = lib.licenses.gpl2;
    maintainers = [ ];
  };
}
