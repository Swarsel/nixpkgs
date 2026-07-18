{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  pillow,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "pypillowfight";
  version = "0.3.1";

  src = fetchFromGitLab {
    owner = "OpenPaperwork";
    repo = "libpillowfight";
    tag = version;
    hash = "sha256-ZH1Eg8GLe3LZ7elohQCYCToEvx8bGaRSrcsT+qSY9s4=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  postPatch = ''
    echo '#define INTERNAL_PILLOWFIGHT_VERSION "${version}"' > src/pillowfight/_version.h
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pillow ];
  pyproject = true;

  meta = {
    inherit (src.meta) homepage;
    description = "Library containing various image processing algorithms";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pyrox0 ];
    # Package has non-portable behavior that makes it not work on Darwin
    # https://github.com/NixOS/nixpkgs/pull/433141#issuecomment-3180885173
    broken = stdenv.hostPlatform.isDarwin;
  };
}
