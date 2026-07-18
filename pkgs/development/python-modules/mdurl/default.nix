{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdurl";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "mdurl";
    tag = finalAttrs.version;
    hash = "sha256-wxV8DKeTwKpFTUBuGTQXaVHc0eW1//Y+2V8Kgs85TDM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "mdurl" ];

  meta = {
    description = "URL utilities for markdown-it";
    homepage = "https://github.com/executablebooks/mdurl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
