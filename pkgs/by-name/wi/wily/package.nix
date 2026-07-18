{
  lib,
  stdenv,
  fetchurl,
  fetchDebianPatch,
  libx11,
  libxt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wily";
  version = "0.13.42";

  src = fetchurl {
    url = "mirror://sourceforge/wily/wily-${finalAttrs.version}.tar.gz";
    sha256 = "1jy4czk39sh365b0mjpj4d5wmymj98x163vmwzyx3j183jqrhm2z";
  };

  patches = [
    ./fix-gcc14-build.patch
    (fetchDebianPatch {
      pname = "wily";
      version = "0.13.42";
      debianRevision = "4";
      hash = "sha256-PZZvn2G/1a4Hk0CMVdDK09vyIN9yQ3X4ToCENwYujFA=";
      patch = "gcc-15.patch";
    })
  ];

  buildInputs = [
    libx11
    libxt
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Emulation of ACME";
    homepage = "http://wily.sourceforge.net";
    license = lib.licenses.artistic1;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "wily";
  };
})
