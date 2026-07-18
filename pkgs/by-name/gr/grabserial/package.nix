{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grabserial";
  version = "2.1.8";

  src = fetchFromGitHub {
    owner = "tbird20d";
    repo = "grabserial";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XHI5r4OkJUtMuH83jKvNttEpKpqARjxj9SDLzhSPxSc=";
  };

  # no usable tests
  doCheck = false;
  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.pyserial ];
  pyproject = true;

  meta = {
    description = "Python based serial dump and timing program";
    homepage = "https://github.com/tbird20d/grabserial";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ vmandela ];
    platforms = lib.platforms.linux;
    mainProgram = "grabserial";
  };
})
