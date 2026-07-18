{
  lib,
  fetchFromGitHub,
  augeas,
  buildPythonPackage,
  cffi,
  pkg-config,
  pkgs, # for libxml2
  setuptools,
  unittestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "augeas";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "hercules-team";
    repo = "python-augeas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lq8ckra3sqN38zo1d5JsEq6U5TtLKRmqysoWNwR9J9A=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    augeas
    pkgs.libxml2
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "augeas" ];

  meta = {
    description = "Pure python bindings for augeas";
    homepage = "https://github.com/hercules-team/python-augeas";
    changelog = "https://github.com/hercules-team/python-augeas/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
})
