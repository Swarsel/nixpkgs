{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "json-merge-patch";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-SgItePwvCctJ2Wxkbvw4DTterStcfaviLDkowsLpxOA=";
    pname = "json_merge_patch";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "JSON Merge Patch library";
    homepage = "https://github.com/open-contracting/json-merge-patch";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "json-merge-patch";
  };
}
