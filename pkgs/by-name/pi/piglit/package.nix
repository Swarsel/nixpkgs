{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  glslang,
  libGL,
  libGLU,
  libffi,
  libgbm,
  libglut,
  libglvnd,
  libx11,
  libxau,
  libxcb,
  libxkbcommon,
  libxrender,
  makeWrapper,
  mesa,
  ninja,
  pkg-config,
  python3,
  vulkan-loader,
  waffle,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "piglit";
  version = "unstable-2026-05-04";

  src = fetchFromGitLab {
    owner = "mesa";
    repo = "piglit";
    rev = "1bb2910c3fced64396feddd205e356d80e5ff7d9";
    hash = "sha256-/3OQeZiK7fHfPpSlFtbW7DLEFV3YFBL1cLMndXyxwYs=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
    pkg-config
  ];

  buildInputs = [
    glslang
    libffi
    libgbm
    libglut
    libGL
    libGLU
    libglvnd
    libxau
    libx11
    libxrender
    libxcb
    libxkbcommon
    (python3.withPackages (
      ps: with ps; [
        mako
        numpy
      ]
    ))
    vulkan-loader
    waffle
    wayland
    wayland-protocols
    wayland-scanner
  ];

  postInstall = ''
    wrapProgram $out/bin/piglit \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libglvnd
        ]
      } \
      --prefix PATH : "${waffle}/bin"
  '';

  # Find data dir: piglit searches for the data directory in some places, however as it is wrapped,
  # it search in ../lib/.piglit-wrapped, we just replace the script name with "piglit" again.
  prePatch = ''
    substituteInPlace piglit \
      --replace 'script_basename_noext = os.path.splitext(os.path.basename(__file__))[0]' 'script_basename_noext = "piglit"'
  '';

  meta = {
    inherit (mesa.meta) platforms;
    description = "OpenGL test suite, and test-suite runner";
    homepage = "https://gitlab.freedesktop.org/mesa/piglit";
    license = lib.licenses.free; # custom license. See COPYING in the source repo.
    maintainers = with lib.maintainers; [ Flakebi ];
    mainProgram = "piglit";
  };
}
