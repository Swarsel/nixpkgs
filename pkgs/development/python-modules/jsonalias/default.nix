{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "jsonalias";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "kevinheavey";
    repo = "jsonalias";
    tag = finalAttrs.version;
    hash = "sha256-1Pb0VpwnAZiv3z+Ur6FS0LV4D9xKvrfAdUtulvr6ACg=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "jsonalias" ];

  meta = {
    description = "Library that defines a Json type alias for Python";
    homepage = "https://github.com/kevinheavey/jsonalias";
    changelog = "https://github.com/kevinheavey/jsonalias/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
