{
  lib,
  stdenv,
  fetchurl,
}:
let
  version = "2.0.88";
  platformMap = {
    aarch64-linux = {
      hash = "sha256-AeW92FU65XVJKGPi+A/iz7Jvtb7wKIO3xG3Cx7v4kRg=";
      url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz-arm64.efi";
    };

    x86_64-linux = {
      hash = "sha256-ipbZJ0mPCuwzb/TDtXXUBTuWOcSsKGAJ1GEGIgB2G7E=";
      url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz.efi";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "netboot.xyz-efi";

  src = fetchurl {
    inherit
      (platformMap.${stdenv.hostPlatform.system}
        or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
      )
      url
      hash
      ;
  };

  postInstall = ''
    cp $src $out
  '';

  dontUnpack = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Tool to boot OS installers and utilities over the network, to be run from a bootloader";
    homepage = "https://netboot.xyz/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ pinpox ];
    platforms = builtins.attrNames platformMap;
  };
})
