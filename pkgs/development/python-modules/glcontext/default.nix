{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libGL,
  libx11,
  setuptools,
}:

buildPythonPackage rec {
  pname = "glcontext";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "moderngl";
    repo = "glcontext";
    tag = version;
    hash = "sha256-GC2sb6xQjg99xLcXSynLOOyyqNwCHZwZqrs9RZh99pY=";
  };

  postPatch = lib.optionalString (stdenv.hostPlatform.isLinux) ''
    substituteInPlace glcontext/x11.cpp \
      --replace-fail '"libGL.so"' '"${libGL}/lib/libGL.so"' \
      --replace-fail '"libX11.so"' '"${libx11}/lib/libX11.so"'
    substituteInPlace glcontext/egl.cpp \
      --replace-fail '"libGL.so"' '"${libGL}/lib/libGL.so"' \
      --replace-fail '"libEGL.so"' '"${libGL}/lib/libEGL.so"'
  '';

  buildInputs = [
    libGL
    libx11
  ];

  # Tests fail because they try to open display. See
  # https://github.com/NixOS/nixpkgs/pull/121439
  # for details.
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "glcontext" ];

  meta = {
    description = "OpenGL implementation for ModernGL";
    homepage = "https://github.com/moderngl/glcontext";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
