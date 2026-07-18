{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  doxygen,
  freetype,
  libGL,
  libGLU,
  libglut,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ftgl";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "frankheckenbach";
    repo = "ftgl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6TDNGoMeBLnucmHRgEDIVWcjlJb7N0sTluqBwRMMWn4=";
  };

  patches = [
    ./fix-warnings.patch
  ];

  # GL_DYLIB is hardcoded to an impure path
  # /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib
  # and breaks build on recent macOS versions
  postPatch = ''
    substituteInPlace m4/gl.m4 \
      --replace ' -dylib_file $GL_DYLIB: $GL_DYLIB' ""
  '';

  nativeBuildInputs = [
    autoreconfHook
    doxygen
    pkg-config
  ];

  buildInputs = [
    freetype
    libGL
    libGLU
    libglut
  ];

  postInstall = ''
    install -Dm644 src/FTSize.h src/FTFace.h -t $out/include/FTGL
  '';

  meta = {
    description = "Font rendering library for OpenGL applications";

    longDescription = ''
      FTGL is a free cross-platform Open Source C++ library that uses Freetype2
      to simplify rendering fonts in OpenGL applications. FTGL supports bitmaps,
      pixmaps, texture maps, outlines, polygon mesh, and extruded polygon
      rendering modes.
    '';

    homepage = "https://github.com/frankheckenbach/ftgl";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
