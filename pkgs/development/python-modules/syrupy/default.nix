{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  hypothesis,
  invoke,
  pydantic,
  pytest,
  pytest-xdist,
}:

buildPythonPackage (finalAttrs: {
  pname = "syrupy";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "syrupy-project";
    repo = "syrupy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tivRKADRYyyNmNOOd0w2qTseA3t7TMwkAkQ/Kr6wp6U=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    hypothesis
    invoke
    pydantic
    pytest
    pytest-xdist
  ];

  checkPhase = ''
    runHook preCheck
    # https://github.com/tophat/syrupy/blob/main/CONTRIBUTING.md#local-development
    invoke test
    runHook postCheck
  '';

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "syrupy" ];

  meta = {
    description = "Pytest Snapshot Test Utility";
    homepage = "https://github.com/syrupy-project/syrupy";
    changelog = "https://github.com/syrupy-project/syrupy/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
