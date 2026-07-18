{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "sseclient-py";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "mpetazzoni";
    repo = "sseclient";
    tag = "sseclient-py-${finalAttrs.version}";
    hash = "sha256-AIldZFElGgSbw38aZWCWI1N35MiE+b9D1s/XhD7aIvo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "sseclient" ];

  meta = {
    description = "Pure-Python Server Side Events (SSE) client";
    homepage = "https://github.com/mpetazzoni/sseclient";
    changelog = "https://github.com/mpetazzoni/sseclient/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
