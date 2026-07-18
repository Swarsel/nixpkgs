{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  autoPatchelfHook,
  makeWrapper,
  ocl-icd,
  vulkan-loader,
}:

let
  inherit (stdenv.hostPlatform.uname) processor;
  version = "6.7.1";
  sources = {
    "aarch64-linux" = {
      hash = "sha256-blmsuD5t6jZx4uKVNl/DfED90oDNvd1QrPJIkQ4UoOM=";
      url = "https://cdn.geekbench.com/Geekbench-${version}-LinuxARMPreview.tar.gz";
    };

    "riscv64-linux" = {
      hash = "sha256-TByNeLqqHrnrLcX/meXNy6Evvebf0/xWnUohd/TwiAk=";
      url = "https://cdn.geekbench.com/Geekbench-${version}-LinuxRISCVPreview.tar.gz";
    };

    "x86_64-linux" = {
      hash = "sha256-Ddypd9622dtL2GZIX5QI5y4oadDeoHN7GNS/5HKFis4=";
      url = "https://cdn.geekbench.com/Geekbench-${version}-Linux.tar.gz";
    };
  };
  geekbench_avx2 = lib.optionalString stdenv.hostPlatform.isx86_64 "geekbench_avx2";
in
stdenv.mkDerivation {
  inherit version;
  pname = "geekbench";

  src = fetchurl (
    sources.${stdenv.system} or (throw "unsupported system ${stdenv.hostPlatform.system}")
  );

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r geekbench.plar geekbench-workload.plar geekbench6 geekbench_${processor} ${geekbench_avx2} $out/bin

    for f in geekbench6 geekbench_${processor} ${geekbench_avx2} ; do
      wrapProgram $out/bin/$f \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            addDriverRunpath.driverLink
            ocl-icd
            vulkan-loader
          ]
        }"
    done

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Cross-platform benchmark";
    homepage = "https://geekbench.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      michalrus
      asininemonkey
    ];

    platforms = builtins.attrNames sources;
    mainProgram = "geekbench6";
  };
}
