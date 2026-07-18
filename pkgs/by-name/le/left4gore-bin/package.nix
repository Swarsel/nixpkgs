{
  lib,
  fetchurl,
  buildFHSEnv,
  stdenvNoCC,
}:

let
  version = "2.3";

  # Unwrapped package, for putting into the FHS env
  left4gore-unwrapped = stdenvNoCC.mkDerivation {
    inherit version;
    pname = "left4gore-unwrapped";

    src = fetchurl {
      url = "http://www.left4gore.com/dist/left4gore-${version}-linux.tar.gz";
      sha256 = "1n57nh32ybn6kirn8djh0nsjx6m84c0jfi1x8r4w2qr0qky3z7p0";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp left4gore $out/bin
    '';
  };

  # FHS env, as patchelf will not work
  env = buildFHSEnv {
    inherit version;
    pname = "left4gore-env";
    runScript = "left4gore";
    targetPkgs = _: [ left4gore-unwrapped ];
  };

in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "left4gore";

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${env}/bin/* $out/bin/left4gore
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  meta = {
    description = "Memory patcher which adds the gore back into Left 4 Dead 2";
    homepage = "http://www.left4gore.com";
    license = lib.licenses.unfree; # Probably the best choice
    maintainers = with lib.maintainers; [ das_j ];
  };
}
