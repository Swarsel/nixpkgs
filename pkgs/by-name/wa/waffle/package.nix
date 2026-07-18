{
  lib,
  stdenv,
  fetchFromGitLab,
  bash-completion,
  cmake,
  libGL,
  libgbm,
  libglvnd,
  libx11,
  libxcb,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  python3,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
  useGbm ? true,
  waylandSupport ? true,
  x11Support ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waffle";
  version = "1.8.3";

  src = fetchFromGitLab {
    owner = "Mesa";
    repo = "waffle";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VvkSZOddxTPukyPpngi4vxni/OqmMGJV7voiiM0uHXo=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    meson
    ninja
    pkg-config
    python3
  ]
  ++ lib.optionals waylandSupport [
    wayland-scanner
  ];

  buildInputs = [
    bash-completion
    libGL
  ]
  ++ lib.optionals (with stdenv.hostPlatform; isUnix && !isDarwin) [
    libglvnd
  ]
  ++ lib.optionals x11Support [
    libx11
    libxcb
  ]
  ++ lib.optionals waylandSupport [
    wayland
    wayland-protocols
  ]
  ++ lib.optionals useGbm [
    udev
    libgbm
  ];

  env.PKG_CONFIG_BASH_COMPLETION_COMPLETIONSDIR = "${placeholder "out"}/share/bash-completion/completions";

  postInstall = ''
    wrapProgram $out/bin/wflinfo \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libglvnd
        ]
      }
  '';

  depsBuildBuild = [ pkg-config ];
  dontUseCmakeConfigure = true;

  meta = {
    inherit (libgbm.meta) platforms;
    description = "Cross-platform C library that allows one to defer selection of an OpenGL API and window system until runtime";
    homepage = "https://www.waffle-gl.org/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ Flakebi ];
    mainProgram = "wflinfo";
  };
})
