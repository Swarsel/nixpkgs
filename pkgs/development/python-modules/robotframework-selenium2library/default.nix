{
  lib,
  buildPythonPackage,
  fetchPypi,
  robotframework-seleniumlibrary,
}:

buildPythonPackage rec {
  pname = "robotframework-selenium2library";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2a8e942b0788b16ded253039008b34d2b46199283461b294f0f41a579c70fda7";
  };

  propagatedBuildInputs = [ robotframework-seleniumlibrary ];
  # Neither the PyPI tarball nor the repository has tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Web testing library for Robot Framework";
    homepage = "https://github.com/robotframework/Selenium2Library";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
