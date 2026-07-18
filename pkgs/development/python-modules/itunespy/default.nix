{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycountry,
  requests,
}:

buildPythonPackage rec {
  pname = "itunespy";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "sleepyfran";
    repo = "itunespy";
    tag = "v${version}";
    sha256 = "sha256-QvSKJAZa8v0tGURXwo4Dwo73JqsYs1xsBHW0lcaM7bk=";
  };

  propagatedBuildInputs = [
    requests
    pycountry
  ];

  # This module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "itunespy" ];

  meta = {
    description = "Simple library to fetch data from the iTunes Store API";
    homepage = "https://github.com/sleepyfran/itunespy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ j0hax ];
  };
}
