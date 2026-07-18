{
  lib,
  buildPythonPackage,
  cysignals,
  cython,
  fetchPypi,
  gmp,
  gmpy2,
  libmpc,
  mpfr,
  ppl,
  # Reverse dependency
  sage,
  sphinx,
}:

buildPythonPackage rec {
  pname = "pplpy";
  version = "0.8.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1CohbIKRTc9NfAAN68mLsza4+D4Ca6XZUszNn4B07/0=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    sphinx # docbuild, called by make
  ];

  buildInputs = [
    gmp
    mpfr
    libmpc
    ppl
  ];

  propagatedBuildInputs = [
    cython
    cysignals
    gmpy2
  ];

  postBuild = ''
    # Find the build result in order to put it into PYTHONPATH. The doc
    # build needs to import pplpy.
    build_result="$PWD/$( find build/ -type d -name 'lib.*' | head -n1 )"

    echo "Building documentation"
    PYTHONPATH="$build_result:$PYTHONPATH" make -C docs html
  '';

  postInstall = ''
    mkdir -p "$doc/share/doc"
    mv docs/build/html "$doc/share/doc/pplpy"
  '';

  format = "setuptools";

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Python wrapper for ppl";
    homepage = "https://gitlab.com/videlec/pplpy";
    license = lib.licenses.gpl3;
    teams = [ lib.teams.sage ];
  };
}
