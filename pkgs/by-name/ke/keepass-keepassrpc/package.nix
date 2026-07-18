{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  mono,
}:

let
  version = "1.16.0";
  drv = stdenv.mkDerivation {
    inherit version;
    pname = "keepassrpc";

    src = fetchurl {
      url = "https://github.com/kee-org/keepassrpc/releases/download/v${version}/KeePassRPC.plgx";
      hash = "sha256-p5dYluCrXAKhBhlm6sQ3QQE3gLMJzEZsHXwGnVeXFos=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = {
      description = "KeePassRPC plugin that needs to be installed inside KeePass in order for Kee to be able to connect your browser to your passwords";
      homepage = "https://github.com/kee-org/keepassrpc";
      license = lib.licenses.gpl2;

      maintainers = with lib.maintainers; [
        svsdep
        mgregoire
      ];

      platforms = [ "x86_64-linux" ];
    };
  };
in
# Mono is required to compile plugin at runtime, after loading.
buildEnv {
  inherit (drv) pname version;

  paths = [
    mono
    drv
  ];
}
