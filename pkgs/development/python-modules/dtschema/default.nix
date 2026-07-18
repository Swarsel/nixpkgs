{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  dtc,
  jsonschema,
  libfdt,
  pytestCheckHook,
  rfc3987,
  ruamel-yaml,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dtschema";
  version = "2026.06";

  src = fetchFromGitHub {
    owner = "devicetree-org";
    repo = "dt-schema";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F0SRUW2Dj3hZymhYYVbHmQ1P7hPApH78eOdfftuic0Y=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    dtc
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    jsonschema
    rfc3987
    ruamel-yaml
    libfdt
  ];

  enabledTestPaths = [ "test/test-dt-validate.py" ];
  pyproject = true;
  pythonImportsCheck = [ "dtschema" ];

  meta = {
    description = "Tooling for devicetree validation using YAML and jsonschema";
    homepage = "https://github.com/devicetree-org/dt-schema/";
    changelog = "https://github.com/devicetree-org/dt-schema/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      bsd2 # or
      gpl2Only
    ];

    maintainers = with lib.maintainers; [ sorki ];
    # Library not loaded: @rpath/libfdt.1.dylib
    broken = stdenv.hostPlatform.isDarwin;
  };
})
