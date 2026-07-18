{
  lib,
  stdenv,
  fetchFromGitLab,
  libconfig,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmegapixels";
  version = "0.2.3";

  src = fetchFromGitLab {
    owner = "megapixels-org";
    repo = "libmegapixels";
    tag = finalAttrs.version;
    hash = "sha256-YYZmjFLAswat++ojUaoYcJk+ruxT3qiuuLWfck23N1c=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libconfig
  ];

  doCheck = true;

  meta = {
    description = "Device abstraction for the Megapixels camera application";
    homepage = "https://gitlab.com/megapixels-org/libmegapixels";
    changelog = "https://gitlab.com/megapixels-org/libmegapixels/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.linux;
  };
})
