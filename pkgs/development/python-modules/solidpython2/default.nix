{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openscad,
  ply,
  poetry-core,
  setuptools,
  withOpenSCAD ? false,
}:
buildPythonPackage rec {
  pname = "solidpython2";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "jeff-dh";
    repo = "SolidPython";
    tag = "v${version}";
    hash = "sha256-3A1vYqIHFUiOH2cEx/XSOien3PmNpMAhLOe3T1yubx4=";
  };

  # NOTE: this patch makes tests runnable outside the source-tree
  # - it uses diff instead of git-diff
  # - modifies the tests output to resemble the paths resulting from running inside the source-tree
  # - drop the openscad image geneneration tests, these don't work on the nix sandbox due to the need for xserver
  patches = [ ./difftool_tests.patch ];
  propagatedBuildInputs = lib.optionals withOpenSCAD [ openscad ];

  checkPhase = ''
    runHook preCheck
    python $TMPDIR/source/tests/run_tests.py
    runHook postCheck
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    ply
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "solid2" ];

  meta = {
    description = "Python frontend for solid modelling that compiles to OpenSCAD";
    homepage = "https://github.com/jeff-dh/SolidPython";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ jonboh ];
  };
}
