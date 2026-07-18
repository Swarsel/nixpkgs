{
  lib,
  stdenv,
  dialog,
  fetchzip,
  glfw,
  glibc,
  libGL,
  libGLU,
  libgccjit,
  libglut,
  libice,
  libsm,
  libx11,
  libxext,
  libxi,
  libxmu,
  lua,
  luabind,
  makeWrapper,
}:
let
  lpath = lib.makeLibraryPath [
    libxmu
    libxi
    libx11
    libglut
    libice
    libGLU
    libGL
    libsm
    libxext
    glibc
    lua
    glfw
    luabind
    libgccjit
  ];
in
stdenv.mkDerivation rec {
  pname = "iceSL";
  version = "2.4.1";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchzip {
        url = "https://icesl.loria.fr/assets/other/download.php?build=${version}&os=amd64";
        sha256 = "0rrnkqkhlsjclif5cjbf17qz64vs95ja49xarxjvq54wb4jhbs4l";
        extension = "zip";
      }
    else if stdenv.hostPlatform.system == "i686-linux" then
      fetchzip {
        url = "https://icesl.loria.fr/assets/other/download.php?build=${version}&os=i386";
        sha256 = "0n2yyxzw0arkc70f0qli4n5chdlh9vc7aqizk4v7825mcglhwlyh";
        extension = "zip";
      }
    else
      throw "Unsupported architecture";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    cp -r ./ $out
    rm $out/bin/*.so
    mkdir $out/oldbin
    mv $out/bin/IceSL-slicer $out/oldbin/IceSL-slicer
    runHook postInstall
  '';

  postInstall = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${lpath}" \
      $out/oldbin/IceSL-slicer
    makeWrapper $out/oldbin/IceSL-slicer $out/bin/icesl --prefix PATH : ${dialog}/bin
  '';

  meta = {
    description = "GPU-accelerated procedural modeler and slicer for 3D printing";
    homepage = "https://icesl.loria.fr/";
    license = lib.licenses.inria-icesl;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ mgttlinger ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
