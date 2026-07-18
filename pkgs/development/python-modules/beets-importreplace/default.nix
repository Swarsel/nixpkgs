{
  lib,
  fetchFromGitHub,
  beets-minimal,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "beets-importreplace";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "edgars-supe";
    repo = "beets-importreplace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lTfHuOBFzBM/uN4GCX6btQy0KRDP/tzG0fp9/qppQtw=";
  };

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "beetsplug.importreplace" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plugin for beets to perform regex replacements during import";
    homepage = "https://github.com/edgars-supe/beets-importreplace";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ pyrox0 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
