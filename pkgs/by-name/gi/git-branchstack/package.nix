{
  lib,
  fetchPypi,
  python3Packages,
}:

let
  self = python3Packages.buildPythonApplication {
    pname = "git-branchstack";
    version = "0.2.0";

    src = fetchPypi {
      inherit (self) version;
      hash = "sha256-gja93LOcVCQ6l+Cygvsm+3uomvxtvUl6t23GIb/tKyQ=";
      pname = "git-branchstack";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      git-revise
    ];

    pyproject = true;

    meta = {
      description = "Efficiently manage Git branches without leaving your local branch";
      homepage = "https://github.com/krobelus/git-branchstack";
      license = lib.licenses.mit;
      maintainers = [ ];
    };
  };
in
self
