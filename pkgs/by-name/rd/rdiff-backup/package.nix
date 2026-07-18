{
  lib,
  fetchPypi,
  librsync,
  python3Packages,
}:

let
  pypkgs = python3Packages;

in
pypkgs.buildPythonApplication (finalAttrs: {
  pname = "rdiff-backup";
  version = "2.2.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-0HeDVyZrxlE7t/daRXCymySydgNIu/YHur/DpvCUWM8";
  };

  buildInputs = [ librsync ];
  # no tests from pypi
  doCheck = false;

  build-system = with pypkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pypkgs; [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "rdiff_backup" ];

  meta = {
    description = "Backup system trying to combine best a mirror and an incremental backup system";
    homepage = "https://rdiff-backup.net";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.all;
    mainProgram = "rdiff-backup";
  };
})
