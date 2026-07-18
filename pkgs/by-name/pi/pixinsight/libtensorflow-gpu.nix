{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cudaPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtensorflow-gpu";
  version = "2.18.1";

  src = fetchurl {
    url = "https://storage.googleapis.com/tensorflow/versions/${finalAttrs.version}/${finalAttrs.pname}-linux-x86_64.tar.gz";
    hash = "sha256-9k7DA53E/hh9zzMhX0D6BZOZWwOoiNEi/tdYHONIFeU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with cudaPackages; [
    cudatoolkit
    cudnn
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -pr --reflink=auto -- . $out

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;

  # Unpack tarball to subdir, preventing copying `env-vars` to $out in `installPhase`
  preUnpack = ''
    mkdir source
    cd source
  '';

  sourceRoot = ".";

  meta = {
    description = "Computation using data flow graphs for scalable machine learning";
    homepage = "http://tensorflow.org";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kulczwoj ];
    platforms = [ "x86_64-linux" ];
  };
})
