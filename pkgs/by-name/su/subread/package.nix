{
  lib,
  stdenv,
  fetchurl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "subread";
  version = "2.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/subread/subread-${finalAttrs.version}/subread-${finalAttrs.version}-source.tar.gz";
    sha256 = "sha256-Y5LXxmgxzddn5YJRiSp5pRtvq47QupZxrV6F/xqwHqo=";
  };

  buildInputs = [
    zlib
  ];

  makeFlags = [ "CC_EXEC=cc" ];

  installPhase = ''
    mkdir $out
    cp -r ../bin $out
  '';

  configurePhase = ''
    runHook preConfigure

    cd src
    cp Makefile.${if stdenv.hostPlatform.isLinux then "Linux" else "MacOS"} Makefile

    runHook postConfigure
  '';

  meta = {
    description = "High-performance read alignment, quantification and mutation discovery";
    homepage = "https://subread.sourceforge.net/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jbedo ];

    platforms = [
      "x86_64-linux"
    ];

    broken = stdenv.hostPlatform.isDarwin;
  };

})
