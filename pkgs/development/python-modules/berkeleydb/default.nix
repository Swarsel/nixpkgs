{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pkgs,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "berkeleydb";
  version = "18.1.15";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-evpTFD11TGuyyFZWwTJeuuUYrc/NG1nhPMKruI3fdY4=";
  };

  # See: https://github.com/NixOS/nixpkgs/pull/311198/files#r1597746759
  env = {
    BERKELEYDB_INCDIR = "${lib.getDev pkgs.db}/include";
    BERKELEYDB_LIBDIR = "${lib.getLib pkgs.db}/lib";
  };

  # Every test currently fails with:
  # berkeleydb.db.DBRunRecoveryError: (-30973, 'BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery -- BDB1546 unable to join the environment')
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkPhase = ''
    ${python.interpreter} test.py
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python bindings for Oracle Berkeley DB";
    homepage = "https://www.jcea.es/programacion/pybsddb.htm";
    license = with lib.licenses; [ bsd3 ];
    maintainers = [ ];
  };
}
