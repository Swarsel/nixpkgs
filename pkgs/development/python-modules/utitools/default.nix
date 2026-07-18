{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "utitools";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "RhetTbull";
    repo = "utitools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mx9vcMCeDTJyWJKm0Ci9IEAPCNfx9NvPGC8cuNYnH1M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = lib.optionals stdenv.hostPlatform.isDarwin [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyproject = true;
  pythonImportsCheck = [ "utitools" ];

  meta = {
    description = "Utilities for working with Uniform Type Identifiers";
    homepage = "https://github.com/RhetTbull/utitools";
    changelog = "https://github.com/RhetTbull/utitools/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    # Requires pyobjc-framework-coreservices and pyobjc-framework-uniformtypeidentifiers
    # which are currently not packaged in nixpgs.
    broken = stdenv.hostPlatform.isDarwin;
  };
})
