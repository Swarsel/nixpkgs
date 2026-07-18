{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "outspin";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "trag1c";
    repo = "outspin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j+J3n/p+DcfnhGfC4/NDBDl5bF39L5kIPeGJW0Zm7ls=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "outspin" ];

  meta = {
    description = "Conveniently read single char inputs in the console";
    homepage = "https://github.com/trag1c/outspin";
    changelog = "https://github.com/trag1c/outspin/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
