{
  lib,
  autoPatchelfHook,
  mkDerivation,
  nvidia-driver,
  nvidia-libs,
}:
mkDerivation {
  inherit (nvidia-driver) src version;
  pname = "nvidia-x11";

  buildInputs = [
    nvidia-libs
  ];

  env.LOCALBASE = "${builtins.placeholder "out"}";

  installPhase = ''
    mkdir -p $out/bin
    make -C x11 install
  '';

  dontBuild = true;

  extraNativeBuildInputs = [
    autoPatchelfHook
  ];

  path = "...";
  meta.license = lib.licenses.unfree;
  meta.platforms = [ "x86_64-freebsd" ];
}
