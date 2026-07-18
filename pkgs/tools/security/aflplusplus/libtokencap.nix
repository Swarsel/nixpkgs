{
  lib,
  stdenv,
  aflplusplus,
}:

stdenv.mkDerivation {
  pname = "libtokencap";
  version = lib.getVersion aflplusplus;
  src = aflplusplus.src;
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preInstall = ''
    mkdir -p $out/lib/afl
    mkdir -p $out/share/doc/afl
  '';

  postInstall = ''
    mkdir $out/bin
    cat > $out/bin/get-libtokencap-so <<END
    #!${stdenv.shell}
    echo $out/lib/afl/libtokencap.so
    END
    chmod +x $out/bin/get-libtokencap-so
  '';

  postUnpack = "chmod -R +w ${aflplusplus.src.name}";
  sourceRoot = "${aflplusplus.src.name}/utils/libtokencap";

  meta = {
    description = "strcmp & memcmp token capture library";
    homepage = "https://github.com/AFLplusplus/AFLplusplus";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      ris
      msanft
    ];
  };
}
