{
  lib,
  stdenv,
  fetchurl,
  libGLU,
  libxext,
  libxi,
  libxmu,
  mesa,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glew";
  version = "1.10.0";

  src = fetchurl {
    url = "mirror://sourceforge/glew/glew-${finalAttrs.version}.tgz";
    sha256 = "01zki46dr5khzlyywr3cg615bcal32dazfazkf360s1znqh17i4r";
  };

  outputs = [
    "out"
    "dev"
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libxmu
    libxi
    libxext
  ];

  propagatedBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ libGLU ]; # GL/glew.h includes GL/glu.h

  makeFlags = [
    "SYSTEM=${if stdenv.hostPlatform.isMinGW then "mingw" else stdenv.hostPlatform.parsed.kernel.name}"
    "CC:=$(CC)"
    "LD:=$(CC)"
  ];

  buildFlags = [ "all" ];

  preInstall = ''
    export GLEW_DEST="$out"
  '';

  postInstall = ''
    mkdir -pv $out/share/doc/glew
    mkdir -p $dev/lib/pkgconfig
    cp glew*.pc $dev/lib/pkgconfig
    cp -r README.txt LICENSE.txt doc $out/share/doc/glew
  '';

  installFlags = [ "install.all" ];

  patchPhase = ''
    sed -i 's|lib64|lib|' config/Makefile.linux
    ${lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
      sed -i -e 's/\(INSTALL.*\)-s/\1/' Makefile
    ''}
  '';

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    inherit (mesa.meta) platforms;
    description = "OpenGL extension loading library for C(++)";
    homepage = "https://glew.sourceforge.net/";
    license = lib.licenses.free; # different files under different licenses
    # The last successful Darwin Hydra build was in 2023
    broken = stdenv.hostPlatform.isDarwin;
    #["BSD" "GLX" "SGI-B" "GPL2"]
    pkgConfigModules = [ "glew" ];
  };
})
