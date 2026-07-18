{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

let
  version = "24.4.24";
in

buildPythonPackage {
  inherit version;
  pname = "fissix";

  src = fetchFromGitHub {
    owner = "amyreese";
    repo = "fissix";
    rev = "v${version}";
    hash = "sha256-geGctke+1PWFqJyiH1pQ0zWj9wVIjV/SQ5njOOk9gOw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ flit-core ];
  dependencies = [ appdirs ];
  pyproject = true;
  pythonImportsCheck = [ "fissix" ];

  meta = {
    description = "Backport of latest lib2to3, with enhancements";
    homepage = "https://github.com/amyreese/fissix";
    license = lib.licenses.psfl;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.emily ];
  };
}
