{
  lib,
  buildPythonPackage,
  chardet,
  fetchPypi,
  six,
  zope-testrunner,
}:

buildPythonPackage rec {
  pname = "ghdiff";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "17mdhi2sq9017nq8rkjhhc87djpi5z99xiil0xz17dyplr7nmkqk";
  };

  propagatedBuildInputs = [
    six
    chardet
  ];

  nativeCheckInputs = [ zope-testrunner ];
  format = "setuptools";

  meta = {
    description = "Generate Github-style HTML for unified diffs";
    homepage = "https://github.com/kilink/ghdiff";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mic92 ];
    mainProgram = "ghdiff";
  };
}
