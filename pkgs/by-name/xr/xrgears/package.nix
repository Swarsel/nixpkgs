{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  glib,
  glm,
  glslang,
  libGL,
  makeWrapper,
  meson,
  ninja,
  openxr-loader,
  pkg-config,
  unstableGitUpdater,
  vulkan-headers,
  vulkan-loader,
  xxd,
}:

stdenv.mkDerivation {
  pname = "xrgears";
  version = "1.0.1-unstable-2026-01-20";

  src = fetchFromGitLab {
    owner = "monado";
    repo = "demos/xrgears";
    rev = "034d3dbb17beb4e393f1524a8508fb353bafebea";
    sha256 = "sha256-nbAwR4bFBSv2tYJgX3uH318uyRGfz9Qxsj+bAxagqIg=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    glslang
    meson
    ninja
    pkg-config
    xxd
    makeWrapper
  ];

  buildInputs = [
    glm
    openxr-loader
    vulkan-headers
    vulkan-loader
    glib
  ];

  fixupPhase = ''
    wrapProgram $out/bin/xrgears \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          SDL2
          libGL
        ]
      }
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "OpenXR example using Vulkan for rendering";
    homepage = "https://gitlab.freedesktop.org/monado/demos/xrgears";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
    mainProgram = "xrgears";
  };
}
