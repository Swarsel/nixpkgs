{
  lib,
  stdenv,
  fetchFromGitHub,
  eglexternalplatform,
  libGL,
  libdrm,
  libgbm,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "egl-gbm";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "egl-gbm";
    tag = finalAttrs.version;
    hash = "sha256-OoHgvFbyd6JakSKyN7N97FMJHNYV1spj7zy3f1g/PN0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    libgbm
    libdrm
    eglexternalplatform
  ];

  __structuredAttrs = true;
  absolutizeEglExternalPlatformIcdJson = true;

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "GBM EGL external platform library";
    homepage = "https://github.com/NVIDIA/egl-gbm/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ccicnce113424
    ];

    platforms = lib.platforms.linux;
  };
})
