{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-mypyc,
  hatchling,
  pytestCheckHook,
  result,
}:

buildPythonPackage (finalAttrs: {
  pname = "crossandra";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "trag1c";
    repo = "crossandra";
    tag = finalAttrs.version;
    hash = "sha256-xKMySbt+Bf+6BGyIKsmYHTZTl25HxlG8hY/HuUtDjSM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-mypyc
  ];

  dependencies = [ result ];
  pyproject = true;
  pythonImportsCheck = [ "crossandra" ];

  meta = {
    description = "Fast and simple enum/regex-based tokenizer with decent configurability";
    homepage = "https://trag1c.github.io/crossandra";
    changelog = "https://github.com/trag1c/crossandra/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
