{
  lib,
  buildPythonPackage,
  fetchFromBitbucket,
  json-handler-registry,
  pytestCheckHook,
  pyyaml,
  setuptools,
  types-pyyaml,
}:

buildPythonPackage (finalAttrs: {
  pname = "tunit";
  version = "1.7.2";

  src = fetchFromBitbucket {
    owner = "massultidev";
    repo = "tunit";
    tag = finalAttrs.version;
    hash = "sha256-S1YEpXQcjQ7gcJPUv4Eo32ypGFkinMjr/x4P/pFMipg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ setuptools ];

  optional-dependencies = {
    json = [ json-handler-registry ];

    yaml = [
      pyyaml
      types-pyyaml
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tunit" ];

  meta = {
    description = "Module for time unit types";
    homepage = "https://bitbucket.org/massultidev/tunit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
