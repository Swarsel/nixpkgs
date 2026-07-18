{
  lib,
  fetchFromGitHub,
  assertpy,
  buildPythonPackage,
  lark,
  pytestCheckHook,
  regex,
  typing-extensions,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycep-parser";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "gruebel";
    repo = "pycep";
    tag = finalAttrs.version;
    hash = "sha256-pEFgpLfGcJhUWfs/nG1r7GfIS045cfNh7MVQokluXmM=";
  };

  # We can't use pythonRelaxDeps to relax the build-system
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build~=0.9.0" "uv_build"
  '';

  nativeCheckInputs = [
    assertpy
    pytestCheckHook
  ];

  build-system = [ uv-build ];

  dependencies = [
    lark
    regex
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycep" ];
  pythonRelaxDeps = [ "regex" ];

  meta = {
    description = "Python based Bicep parser";
    homepage = "https://github.com/gruebel/pycep";
    changelog = "https://github.com/gruebel/pycep/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
