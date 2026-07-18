{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "stringcase";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "023hv3gknblhf9lx5kmkcchzmbhkdhmsnknkv7lfy20rcs06k828";
  };

  # PyPi package does not include tests.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Convert string cases between camel case, pascal case, snake case etc…";
    homepage = "https://github.com/okunishinishi/python-stringcase";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alunduil ];
  };
}
