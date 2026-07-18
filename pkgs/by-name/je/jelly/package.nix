{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "jelly";
  version = "0.1.31";

  src = fetchFromGitHub {
    owner = "DennisMitchell";
    repo = "jellylanguage";
    rev = "70c9fd93ab009c05dc396f8cc091f72b212fb188";
    sha256 = "1rpclqagvigp5qhvgnjavvy463f1drshnc1mfxm6z7ygzs0l0yz6";
  };

  # checks are disabled because jelly has no tests, and the default is to run
  # the output binary with no arguments, which exits with status 1 and causes
  # the build to fail
  doCheck = false;
  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.sympy ];
  pyproject = true;

  meta = {
    description = "Recreational programming language inspired by J";
    homepage = "https://github.com/DennisMitchell/jellylanguage";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.tckmn ];
    platforms = lib.platforms.all;
    mainProgram = "jelly";
  };
}
