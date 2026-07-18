{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "ratelim";
  version = "0.1.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "07dirdd8y23706110nb0lfz5pzbrcvd9y74h64la3y8igqbk4vc2";
  };

  propagatedBuildInputs = [ decorator ];
  # package has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "ratelim" ];

  meta = {
    description = "Simple Python library that limits the number of times a function can be called during a time interval";
    homepage = "https://github.com/themiurgo/ratelim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dgliwka ];
  };
}
