{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  requests-cache,
}:

buildPythonPackage {
  pname = "tvdb-api";
  version = "3.2.0-beta";

  src = fetchFromGitHub {
    owner = "dbr";
    repo = "tvdb_api";
    rev = "ce0382181a9e08a5113bfee0fed2c78f8b1e613f";
    hash = "sha256-poUuwySr6+8U9PIHhqFaR7nXzh8kSaW7mZkuKTUJKj8=";
  };

  propagatedBuildInputs = [ requests-cache ];
  # requires network access
  doCheck = false;
  nativeCheckInputs = [ pytest ];
  format = "setuptools";

  meta = {
    description = "Simple to use TVDB (thetvdb.com) API in Python";
    homepage = "https://github.com/dbr/tvdb_api";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
