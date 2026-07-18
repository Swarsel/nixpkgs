{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  libopus,
  pytestCheckHook,
  replaceVars,
}:

buildPythonPackage (finalAttrs: {
  pname = "opuslib-next";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "kalicyh";
    repo = "opuslib-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rR1tsijKUBUH3bZZSISsx1JUO35TZevcTcfPtoQow/E=";
  };

  patches = [
    (replaceVars ./ctypes.patch {
      libopus = "${lib.getLib libopus}/lib/libopus${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  buildInputs = [
    libopus
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "opuslib_next"
  ];

  meta = {
    description = "Python bindings to the libopus, IETF low-delay audio codec";
    homepage = "https://github.com/kalicyh/opuslib-next";
    changelog = "https://github.com/kalicyh/opuslib-next/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
