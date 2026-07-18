{
  lib,
  babel,
  buildPythonPackage,
  fetchPypi,
  humanize,
  python-dateutil,
  pytz,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "delorean";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/md4bhIzhSOEi+xViKZYxNQl4S1T61HP74cL7I9XYTQ=";
    pname = "Delorean";
  };

  propagatedBuildInputs = [
    babel
    humanize
    python-dateutil
    pytz
    tzlocal
  ];

  # test data not included
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "delorean" ];

  meta = {
    description = "Delorean: Time Travel Made Easy";
    homepage = "https://github.com/myusuf3/delorean";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
