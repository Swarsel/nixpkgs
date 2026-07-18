{
  lib,
  stdenv,
  fetchFromGitHub,
  eglexternalplatform,
  libGL,
  libdrm,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "egl-wayland";
  version = "1.1.21";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "egl-wayland";
    tag = finalAttrs.version;
    hash = "sha256-a98DzmzCG6DlLJ1HCl/LeD21Q7yyNbTce1poOoAnTjA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Declares an includedir but doesn't install any headers
    # CMake's `pkg_check_modules(NAME wayland-eglstream IMPORTED_TARGET)` considers this an error
    sed -i -e '/includedir/d' wayland-eglstream.pc.in
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    libdrm
    wayland
    wayland-protocols
  ];

  propagatedBuildInputs = [
    eglexternalplatform
  ];

  __structuredAttrs = true;
  absolutizeEglExternalPlatformIcdJson = true;

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "EGLStream-based Wayland external platform";
    homepage = "https://github.com/NVIDIA/egl-wayland/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
