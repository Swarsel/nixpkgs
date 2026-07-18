{
  lib,
  buildPythonPackage,
  cysignals,
  cython,
  fetchPypi,
  gmp,
  meson-python,
  pari,
  pkg-config,
  python,
  # Reverse dependency
  sage,
}:

buildPythonPackage rec {
  pname = "cypari2";
  # upgrade may break sage, please test the sage build or ping @timokau on upgrade
  version = "2.2.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+fDplKmgsGRhkyBBHh2cMDFYhH4FW1gILv2t5ayX9hM=";
  };

  nativeBuildInputs = [
    pari
    pkg-config
  ];

  buildInputs = [
    gmp
    pari
  ];

  preConfigure = ''
    substituteInPlace cypari2/meson.build \
       --replace-fail "'cypari2.py'" "'cypari2.pc'"
  '';

  checkPhase = ''
    test -f "$out/${python.sitePackages}/cypari2/auto_paridecl.pxd"
    make check
  '';

  build-system = [
    meson-python
    cython
    cysignals
  ];

  pyproject = true;

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Cython bindings for PARI";
    homepage = "https://github.com/defeo/cypari2";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.sage ];
  };
}
