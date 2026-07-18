{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mlarchive2maildir";
  version = "0.0.9";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "02zjwa7zbcbqj76l0qmg7bbf3fqli60pl2apby3j4zwzcrrryczs";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    click
    click-log
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "mlarchive2maildir" ];

  meta = {
    description = "Imports mail from (pipermail) archives into a maildir";
    homepage = "https://github.com/flokli/mlarchive2maildir";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
    mainProgram = "mlarchive2maildir";
  };
})
