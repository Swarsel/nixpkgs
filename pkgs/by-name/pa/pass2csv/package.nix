{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pass2csv";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IdcSwQ9O2HmCvT8p4tC7e2GQuhkE3kvMINszZH970og=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    python-gnupg
  ];

  # Project has no tests.
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Export pass(1), \"Standard unix password manager\", to CSV";
    homepage = "https://codeberg.org/svartstare/pass2csv";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pass2csv";
  };
}
