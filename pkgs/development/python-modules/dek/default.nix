{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  xmod,
}:

buildPythonPackage rec {
  pname = "dek";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "rec";
    repo = "dek";
    rev = "v${version}";
    hash = "sha256-DYODdImTRCukGmGbkZ+9TQeI9DYaeRd/EHS6VND5IDs=";
  };

  nativeBuildInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ xmod ];
  pyproject = true;
  pythonImportsCheck = [ "dek" ];

  meta = {
    description = "Decorator-decorator";
    homepage = "https://github.com/rec/dek";
    changelog = "https://github.com/rec/dek/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
