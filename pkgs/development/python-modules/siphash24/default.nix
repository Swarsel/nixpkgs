{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  c-siphash,
  cython,
  meson,
  meson-python,
  pkg-config,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "siphash24";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "dnicolodi";
    repo = "python-siphash24";
    tag = "v${finalAttrs.version}";
    hash = "sha256-51LgmB30MDTBRoZttIESopWMdrozvLFwlxYELmqu5UQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    c-siphash
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    meson
    meson-python
    cython
  ];

  enabledTestPaths = [ "test.py" ];
  pyproject = true;

  pythonImportsCheck = [
    "siphash24"
  ];

  meta = {
    description = "Streaming-capable SipHash Implementation";
    homepage = "https://github.com/dnicolodi/python-siphash24";
    changelog = "https://github.com/dnicolodi/python-siphash24/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
