{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  six,
}:

buildPythonPackage rec {
  pname = "jsondate";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ilya-kolpakov";
    repo = "jsondate";
    tag = "v${version}";
    sha256 = "0nhvi48nc0bmad5ncyn6c9yc338krs3xf10bvv55xgz25c5gdgwy";
    fetchSubmodules = true; # Fetching by tag does not work otherwise
  };

  propagatedBuildInputs = [ six ];
  format = "setuptools";

  meta = {
    description = "JSON with datetime handling";
    homepage = "https://github.com/ilya-kolpakov/jsondate";
    license = lib.licenses.mit;
  };
}
