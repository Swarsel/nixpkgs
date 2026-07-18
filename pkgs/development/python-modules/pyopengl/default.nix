{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  mesa,
  pkgs,
  replaceVars,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyopengl";
  version = "3.1.10";

  src = fetchFromGitHub {
    owner = "mcfletch";
    repo = "pyopengl";
    tag = finalAttrs.version;
    hash = "sha256-U/7J3EoxKHp/dR2LAzTiwR5wcjZbUBuT5Dt3c76xxj4=";
  };

  patches = lib.optionals (finalAttrs.passthru.runtimeLibs != [ ]) [
    # patch OpenGL.platform.ctypesloader::_loadLibraryPosix with extra search paths
    (replaceVars ./ld-preload-gl.patch {
      GL_LD_LIBRARY_PATH = lib.makeLibraryPath finalAttrs.passthru.runtimeLibs;
    })
  ];

  # mosts tests fail in the nix sandbox with:
  #  GLX is not supported
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  # PyOpenGL looks for libraries during import, making this a somewhat decent test of our patching
  # (these are impure deps on darwin)
  pythonImportsCheck = [
    "OpenGL"
    "OpenGL.GL"
    "OpenGL.GLE"
    "OpenGL.GLU"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "OpenGL.EGL"
    "OpenGL.GLES1"
    "OpenGL.GLES2"
    "OpenGL.GLES3"
    "OpenGL.GLX"
  ];

  passthru.runtimeLibs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "/run/opengl-driver/lib"
    pkgs.libglvnd
    pkgs.libGLU
    pkgs.libglut
    pkgs.gle
  ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "PyOpenGL, the Python OpenGL bindings";

    longDescription = ''
      PyOpenGL is the cross platform Python binding to OpenGL and related APIs.
    '';

    homepage = "https://mcfletch.github.io/pyopengl/";
    license = lib.licenses.bsd3;
  };
})
