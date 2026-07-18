{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crossandra,
  dahlia,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "samarium";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "samarium-lang";
    repo = "samarium";
    tag = finalAttrs.version;
    hash = "sha256-sOkJ67B8LaIA2cwCHaFnc16lMG8uaegBJCzF6Li77vk=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    crossandra
    dahlia
  ];

  pyproject = true;

  meta = {
    description = "Samarium Programming Language";
    homepage = "https://samarium-lang.github.io/Samarium";
    changelog = "https://github.com/samarium-lang/samarium/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
