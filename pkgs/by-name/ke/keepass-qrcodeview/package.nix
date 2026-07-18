{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  mono,
}:

let
  version = "1.0.4";

  drv = stdenv.mkDerivation {
    inherit version;
    pname = "keepass-qrcodeview";

    src = fetchurl {
      url = "https://github.com/JanisEst/KeePassQRCodeView/releases/download/v${version}/KeePassQRCodeView.plgx";
      sha256 = "e13c9f02bb0d79b479ca0e92490b822b5b88f49bb18ba2954d3bbe0808f46e6d";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = {
      description = "Enables KeePass to display data as QR code images";

      longDescription = ''
        KeePassQRCodeView is a plugin for KeePass 2.x which shows QR codes for entry fields.
        These codes can be scanned to copy the encoded data to the scanner (smartphone, ...)
      '';

      homepage = "https://github.com/JanisEst/KeePassQRCodeView";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ nazarewk ];

      platforms = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
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
