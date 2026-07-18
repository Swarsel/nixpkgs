{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretix-plugin-build,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pretix-fontpack-free";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-fontpack-free";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eeU8awLf/PSsLuAOobZhXVyQ3KM7jOEIz1ZLt4eDxzQ=";
  };

  __structuredAttrs = true;

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_fontpackfree"
  ];

  meta = {
    description = "Set of free fonts for pretix";
    homepage = "https://github.com/pretix/pretix-fontpack-free";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
