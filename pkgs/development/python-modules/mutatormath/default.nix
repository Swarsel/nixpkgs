{
  lib,
  buildPythonPackage,
  defcon,
  fetchPypi,
  fontmath,
  setuptools,
  unicodedata2,
}:

buildPythonPackage (finalAttrs: {
  pname = "mutatormath";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "0r1qq45np49x14zz1zwkaayqrn7m8dn2jlipjldg2ihnmpzw29w1";
    extension = "zip";
    pname = "MutatorMath";
  };

  checkPhase = ''
    runHook preCheck

    python Lib/mutatorMath/test/run.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    fontmath
    unicodedata2
    defcon
  ];

  pyproject = true;

  meta = {
    description = "Piecewise linear interpolation in multiple dimensions with multiple, arbitrarily placed, masters";
    homepage = "https://github.com/LettError/MutatorMath";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
