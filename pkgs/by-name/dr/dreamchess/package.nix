{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  bison,
  cmake,
  expat,
  flex,
  freetype,
  gettext,
  glew,
  libGL,
  libGLU,
  libsm,
  libx11,
  libxcb,
  libxext,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dreamchess";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dreamchess";
    repo = "dreamchess";
    rev = "${finalAttrs.version}";
    hash = "sha256-qus/RjwdAl9SuDXfLVKTPImqrvPF3xSDVlbXYLM3JNE=";
  };

  patches = [
    ### Fix cmake minimum version
    ./0000-fix-cmake-min.patch
  ];

  nativeBuildInputs = [
    cmake
    bison
    flex
    gettext
    makeWrapper
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    expat
    glew
    freetype
    libsm
    libxext
    libGL
    libGLU
    libxcb
    libx11
  ];

  cmakeFlags = [
    (lib.cmakeBool "CMAKE_VERBOSE_MAKEFILE" true)
    (lib.cmakeFeature "OpenGL_GL_PREFERENCE" "GLVND")
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
  ];

  doInstallCheck = true;

  # This makes sure the default engine (dreamer) will be called from
  # the /nix/store/ as well when starting a new game
  postFixup = ''
    wrapProgram $out/bin/dreamchess \
      --prefix PATH : $out/bin
  '';

  postInstallCheck = ''
    stat "''${!outputBin}/bin/${finalAttrs.meta.mainProgram}"
    stat "''${!outputBin}/bin/dreamer"
  '';

  meta = {
    description = "OpenGL Chess Game";
    homepage = "https://github.com/dreamchess/dreamchess";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ spk ];
    platforms = lib.platforms.linux;
    mainProgram = "dreamchess";
  };
})
