{
  lib,
  autoPatchelfHook,
  mkDerivation,
  nvidia-driver,
  nvidia-libs,
}:
mkDerivation {
  inherit (nvidia-driver) src version;
  pname = "nvidia-nvml";
  buildInputs = [ nvidia-libs ];
  env.LOCALBASE = "${builtins.placeholder "out"}";

  installPhase = ''
    mkdir -p $out/bin
    make -C nvml install
  '';

  dontBuild = true;

  extraNativeBuildInputs = [
    autoPatchelfHook
  ];

  path = "...";
  runtimeDependencies = [ nvidia-libs ];
  meta.license = lib.licenses.unfree;
  meta.platforms = [ "x86_64-freebsd" ];
}
