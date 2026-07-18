{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  replaceVars,
  setuptools,
  unrar,
}:
buildPythonPackage rec {
  pname = "python-unrar";
  version = "0.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-skRHpbkwJL5gDvglVmi6I6MPRRF2V3tpFVnqE1n30WQ=";
    pname = "unrar";
  };

  patches = [
    (replaceVars ./use_nix_unrar_path.patch {
      unrar_lib_path = "${unrar}/lib/libunrar${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  doCheck = true;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "unrar" ];

  meta = {
    description = "Wrapper for UnRAR library, plus a rarfile module on top of it";
    homepage = "http://github.com/matiasb/python-unrar";
    changelog = "https://github.com/matiasb/python-unrar/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ DrymarchonShaun ];
    platforms = lib.platforms.linux;
  };
}
