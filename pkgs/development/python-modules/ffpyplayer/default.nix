{
  lib,
  fetchFromGitHub,
  # buildInputs
  SDL2,
  buildPythonPackage,
  # build-system
  cython,
  # ffpyplayer is not compatible with ffmpeg 7
  # https://github.com/matham/ffpyplayer/issues/16
  ffmpeg_6,
  pkg-config,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ffpyplayer";
  version = "4.5.3";

  src = fetchFromGitHub {
    owner = "matham";
    repo = "ffpyplayer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dzSORPNXQ82d9fmfuQa8RcxDu5WbUBJEDG/SWQLJ6i0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "cython~=3.0.11" \
        "cython"
    substituteInPlace setup.py \
      --replace-fail \
        "cython~=3.0.11" \
        "cython"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    (lib.getDev SDL2)
    (lib.getDev ffmpeg_6)
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
      "-Wno-error=incompatible-pointer-types"
    ];
  };

  # No proper test suite
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "ffpyplayer" ];

  meta = {
    description = "A cython implementation of an ffmpeg based player";
    homepage = "https://github.com/matham/ffpyplayer";
    changelog = "https://github.com/matham/ffpyplayer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
