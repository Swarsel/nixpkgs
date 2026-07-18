{
  lib,
  stdenv,
  fetchurl,
  patchelf,
}:
stdenv.mkDerivation rec {
  pname = "mlc";
  version = "3.9a";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/736634/mlc_v${version}.tgz";
    sha256 = "EDa5V56qCPQxgCu4eddYiWDrk7vkYS0jisnG004L+jQ=";
  };

  nativeBuildInputs = [ patchelf ];

  installPhase = ''
    install -Dm755 mlc $out/bin/mlc
  '';

  fixupPhase = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/mlc
  '';

  sourceRoot = "Linux";

  meta = {
    description = "Intel Memory Latency Checker";
    homepage = "https://software.intel.com/content/www/us/en/develop/articles/intelr-memory-latency-checker.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ basvandijk ];
    platforms = with lib.platforms; linux;
    mainProgram = "mlc";
  };
}
