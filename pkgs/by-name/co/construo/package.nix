{
  lib,
  stdenv,
  fetchurl,
  apple-sdk,
  libGL,
  libGLU,
  libglut,
  libx11,
  xorgproto,
  zlib,
  withLibGL ? !stdenv.hostPlatform.isDarwin,
  withLibGLU ? !stdenv.hostPlatform.isDarwin,
  withLibglut ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "construo";
  version = "0.2.3";

  src = fetchurl {
    url = "https://github.com/Construo/construo/releases/download/v${finalAttrs.version}/construo-${finalAttrs.version}.tar.gz";
    sha256 = "1wmj527hbj1qv44cdsj6ahfjrnrjwg2dp8gdick8nd07vm062qxa";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure --replace-fail \
      '-I/System/Library/Frameworks/GLUT.framework/Headers/' \
      '-I${apple-sdk}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/GLUT.framework/Headers/'
  '';

  buildInputs = [
    libx11
    zlib
    xorgproto
  ]
  ++ lib.optional withLibGL libGL
  ++ lib.optional withLibGLU libGLU
  ++ lib.optional withLibglut libglut
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk ];

  env.CXXFLAGS = "-std=c++98";

  preConfigure = ''
    substituteInPlace src/Makefile.in \
      --replace games bin
  '';

  meta = {
    description = "Masses and springs simulation game";
    homepage = "http://fs.fsf.org/construo/";
    license = lib.licenses.gpl3;
    mainProgram = "construo.x11";
    priority = 10;
  };
})
