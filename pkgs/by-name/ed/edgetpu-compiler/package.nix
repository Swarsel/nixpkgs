{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  libcxx,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "edgetpu-compiler";
  version = "15.0";

  src = fetchurl rec {
    url = "https://packages.cloud.google.com/apt/pool/edgetpu-compiler_${finalAttrs.version}_amd64_${sha256}.deb";
    sha256 = "ce03822053c2bddbb8640eaa988396ae66f9bc6b9d6d671914acd1727c2b445a";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    libcxx
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./{bin,share} $out

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    mkdir bin pkg

    dpkg -x $src pkg

    rm -r pkg/usr/share/lintian

    cp pkg/usr/bin/edgetpu_compiler_bin/edgetpu_compiler ./bin
    cp -r pkg/usr/share .

    rm -r pkg
  '';

  meta = {
    description = "Command line tool that compiles a TensorFlow Lite model into an Edge TPU compatible file";
    homepage = "https://coral.ai/docs/edgetpu/compiler";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "edgetpu_compiler";
  };
})
