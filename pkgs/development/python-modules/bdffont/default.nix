{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "bdffont";
  version = "0.0.40";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "bdffont";
    tag = finalAttrs.version;
    hash = "sha256-gIdnkHA0TWOOgQv3BNl9lf0KKkdLSa9PeQJhf99fsGo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  pyproject = true;
  pythonImportsCheck = [ "bdffont" ];

  meta = {
    description = "Library for manipulating Glyph Bitmap Distribution Format (BDF) Fonts";
    homepage = "https://github.com/TakWolf/bdffont";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];

    platforms = lib.platforms.all;
  };
})
