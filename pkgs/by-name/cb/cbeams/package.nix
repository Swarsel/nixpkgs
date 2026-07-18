{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cbeams";
  version = "1.0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-8Q2sWsAc39Mu34K1wWOKOJERKzBStE4GmtuzOs2T7Kk=";
  };

  postPatch = ''
    substituteInPlace cbeams/terminal.py \
      --replace-fail "blessings" "blessed"
  '';

  doCheck = false; # no tests
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    blessed
    docopt
  ];

  disabled = !python3Packages.isPy3k;
  pyproject = true;
  pythonRemoveDeps = [ "blessings" ];

  meta = {
    description = "Command-line program to draw animated colored circles in the terminal";
    homepage = "https://github.com/tartley/cbeams";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      sigmanificient
    ];
  };
})
