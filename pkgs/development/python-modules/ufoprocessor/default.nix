{
  lib,
  buildPythonPackage,
  defcon,
  fetchPypi,
  fontmath,
  fontparts,
  fonttools,
  fs,
  lxml,
  mutatormath,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ufoprocessor";
  version = "1.14.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-/TjTzDWblBcbqNP9weTe/eIgas70+X11tIUDu4rAOwE=";
  };

  checkPhase = ''
    runHook preCheck
    for t in Tests/*.py; do
      python "$t"
    done
    runHook postCheck
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    defcon
    fontmath
    fontparts
    fonttools
    mutatormath
  ]
  ++ defcon.optional-dependencies.lxml
  ++ fonttools.optional-dependencies.lxml
  ++ fonttools.optional-dependencies.ufo;

  pyproject = true;

  meta = {
    description = "Read, write and generate UFOs with designspace data";
    homepage = "https://github.com/LettError/ufoProcessor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
