{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymetar";
  version = "1.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SNvmxJKZYQIcth5Ju54GBbVMS2G5+5reUQdnBaCOzVQ=";
  };

  checkPhase = ''
    cd testing/smoketest
    tar xzf reports.tgz
    mkdir logs
    patchShebangs runtests.sh
    substituteInPlace runtests.sh --replace-fail "break" "exit 1"  # fail properly
    export PYTHONPATH="$PYTHONPATH:$out/${python.sitePackages}"
    ./runtests.sh
  '';

  build-system = [ setuptools ];
  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Command-line tool to show the weather report by a given station ID";
    homepage = "https://github.com/klausman/pymetar";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ erosennin ];
    mainProgram = "pymetar";
  };
}
