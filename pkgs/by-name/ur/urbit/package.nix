{
  lib,
  stdenv,
  fetchurl,
}:

let
  os = if stdenv.hostPlatform.isDarwin then "macos" else "linux";
  arch = if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64";
  platform = "${os}-${arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "urbit";
  version = "4.6";

  src = fetchurl {
    url = "https://github.com/urbit/vere/releases/download/vere-v${finalAttrs.version}/${platform}.tgz";

    sha256 =
      {
        aarch64-darwin = "0dsapvlyfr2cb9c16b46bcnvq75by87ybys96zhf16k92z4rzrfv";
        aarch64-linux = "126hw995xipbx9kb4ml8kn6xwkwd96q90cbr3q143ya2wl1sabya";
        x86_64-linux = "1bm32airwqi6pkxlkd0hwrwd0gwm9x5y05dzgy27yxnbcrnyjcpk";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
  };

  postInstall = ''
    install -m755 -D src/vere-v${finalAttrs.version}-${platform} $out/bin/urbit
  '';

  unpackPhase = ''
    mkdir src
    tar -C src -xf $src
  '';

  passthru.updateScript = ./update-bin.sh;

  meta = {
    description = "Operating function";
    homepage = "https://urbit.org";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.matthew-levan ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "urbit";
  };
})
