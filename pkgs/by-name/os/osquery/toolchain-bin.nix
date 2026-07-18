{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchzip,
}:
let

  version = "1.1.0";

  dist = {
    "aarch64-linux" = {
      hash = "sha256-cQlx9AtO6ggIQqHowa+42wQ4YCMCN4Gb+0qqVl2JElw=";
      url = "https://github.com/osquery/osquery-toolchain/releases/download/${version}/osquery-toolchain-${version}-aarch64.tar.xz";
    };

    "x86_64-linux" = {
      hash = "sha256-irekR8a0d+T64+ZObgblsLoc4kVBmb6Gv0Qf8dLDCMk=";
      url = "https://github.com/osquery/osquery-toolchain/releases/download/${version}/osquery-toolchain-${version}-x86_64.tar.xz";
    };
  };

in

stdenv.mkDerivation {

  inherit version;
  src = fetchzip dist.${stdenv.hostPlatform.system};
  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  name = "osquery-toolchain-bin";

  meta = {
    description = "LLVM-based toolchain for Linux designed to build a portable osquery";
    homepage = "https://github.com/osquery/osquery-toolchain";

    license = with lib.licenses; [
      gpl2Only
      asl20
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
