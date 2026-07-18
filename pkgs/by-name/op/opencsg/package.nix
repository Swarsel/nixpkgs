{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fixDarwinDylibNames,
  glew,
  libGL,
  libGLU,
  libglut,
  libx11,
  libxext,
  libxmu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencsg";
  version = "1.8.2";

  src = fetchurl {
    url = "https://www.opencsg.org/OpenCSG-${finalAttrs.version}.tar.gz";
    hash = "sha256-WsXfc7GtM0DdZwX/kOAJ8alGu5U2whwiY6b5dCZWZMA=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./opencsgexample.patch ];
  nativeBuildInputs = [ cmake ] ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    glew
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGLU
    libGL
    libglut
    libxmu
    libxext
    libx11
  ];

  doCheck = false;

  postInstall = ''
    install -D ../copying.txt "$out/share/doc/opencsg/copying.txt"
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    app=$out/Applications/opencsgexample.app/Contents/MacOS/opencsgexample
    install_name_tool -change \
      $(otool -L $app | awk '/opencsg.+dylib/ { print $1 }') \
      $(otool -D $out/lib/libopencsg.dylib | tail -n 1) \
      $app
  '';

  meta = {
    description = "Constructive Solid Geometry library";
    homepage = "http://www.opencsg.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "opencsgexample";
  };
})
