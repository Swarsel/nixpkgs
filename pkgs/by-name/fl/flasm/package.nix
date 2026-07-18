{
  lib,
  stdenv,
  bison,
  fetchpatch,
  fetchzip,
  flex,
  gperf,
  unzip,
  zlib,
}:

stdenv.mkDerivation {
  pname = "flasm";
  version = "1.64";

  src = fetchzip {
    url = "https://www.nowrap.de/download/flasm16src.zip";
    sha256 = "03hvxm66rb6rjwbr07hc3k7ia5rim2xlhxbd9qmcai9xwmyiqafg";
    stripRoot = false;
  };

  patches = [
    # Pull patch pending upstream inclusion for -fno-common toolchains:
    #  https://sourceforge.net/p/flasm/patches/2/
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "0ic7k1mmyvhpnxam89dbg8i9bfzk70zslfdxgpmkszx097bj1hv6";
      url = "https://sourceforge.net/p/flasm/patches/2/attachment/0001-flasm-fix-build-on-gcc-10-fno-common.patch";
    })
  ];

  nativeBuildInputs = [
    unzip
    bison
    flex
    gperf
  ];

  buildInputs = [ zlib ];
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    install -Dm755 flasm -t $out/bin
  '';

  meta = {
    description = "Assembler and disassembler for Flash (SWF) bytecode";
    homepage = "https://flasm.sourceforge.net/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "flasm";
  };
}
