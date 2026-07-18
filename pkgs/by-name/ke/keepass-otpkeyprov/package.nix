{
  lib,
  stdenv,
  buildEnv,
  fetchzip,
  mono,
}:

let
  version = "2.6";
  drv = stdenv.mkDerivation {
    inherit version;
    pname = "otpkeyprov";

    src = fetchzip {
      url = "https://keepass.info/extensions/v2/otpkeyprov/OtpKeyProv-${version}.zip";
      sha256 = "1p60k55v2sxnv1varmp0dgbsi2rhjg9kj19cf54mkc87nss5h1ki";
      stripRoot = false;
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $pluginFilename $out/lib/dotnet/keepass/$pluginFilename
    '';

    pluginFilename = "OtpKeyProv.plgx";

    meta = {
      description = "Key provider based on one-time passwords";
      homepage = "https://keepass.info/plugins.html#otpkeyprov";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.Enteee ];
      platforms = with lib.platforms; linux;
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
