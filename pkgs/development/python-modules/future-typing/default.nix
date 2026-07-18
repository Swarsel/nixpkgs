{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "future-typing";
  version = "0.4.1";

  src = fetchPypi {
    inherit version;
    sha256 = "65fdc5034a95db212790fee5e977fb0a2df8deb60dccf3bac17d6d2b1a9bbacd";
    pname = "future_typing";
  };

  doCheck = false; # No tests in pypi source. Did not get tests from GitHub source to work.
  format = "setuptools";
  pythonImportsCheck = [ "future_typing" ];

  meta = {
    description = "Use generic type hints and new union syntax `|` with python 3.6+";
    homepage = "https://github.com/PrettyWood/future-typing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kfollesdal ];
    mainProgram = "future_typing";
  };
}
