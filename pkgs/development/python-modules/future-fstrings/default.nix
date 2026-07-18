{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "future-fstrings";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    sha256 = "6cf41cbe97c398ab5a81168ce0dbb8ad95862d3caf23c21e4430627b90844089";
    pname = "future_fstrings";
  };

  # No tests included in Pypi archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Backport of fstrings to python<3.6";
    homepage = "https://github.com/asottile/future-fstrings";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
    mainProgram = "future-fstrings-show";
  };
}
