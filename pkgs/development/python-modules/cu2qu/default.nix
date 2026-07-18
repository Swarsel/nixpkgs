{
  lib,
  buildPythonPackage,
  # build
  cython,
  # propagates
  defcon,
  fetchPypi,
  fonttools,
  # tests
  pytestCheckHook,
  setuptools-scm,
  setuptools_80,
}:

let
  pname = "cu2qu";
  version = "1.6.7.post2";
in
buildPythonPackage rec {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HfVi2ZvWBZImCI9ENwK/Uc/djMY2I/IxN0WaeNe/WAg=";
    extension = "zip";
  };

  nativeBuildInputs = [
    cython
    setuptools_80
    setuptools-scm
  ];

  propagatedBuildInputs = [
    defcon
    fonttools
  ]
  ++ fonttools.optional-dependencies.ufo;

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Cubic-to-quadratic bezier curve conversion";
    homepage = "https://github.com/googlefonts/cu2qu";
    changelog = "https://github.com/googlefonts/cu2qu/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "cu2qu";
  };
}
