{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  glibcLocales,
  numpy,
  pytestCheckHook,
  scipy,
  spglib,
}:

buildPythonPackage rec {
  pname = "seekpath";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "giovannipizzi";
    repo = "seekpath";
    tag = "v${version}";
    hash = "sha256-mrutQCSSiiLPt0KEohZeYcQ8aw2Jhy02bEvn6Of8w6U=";
  };

  nativeBuildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.utf-8";
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.bz;
  build-system = [ flit-core ];

  dependencies = [
    numpy
    spglib
  ];

  optional-dependencies = {
    bz = [ scipy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "seekpath" ];

  meta = {
    description = "Module to obtain and visualize band paths in the Brillouin zone of crystal structures";
    homepage = "https://github.com/giovannipizzi/seekpath";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
