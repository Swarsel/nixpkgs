{
  lib,
  stdenv,
  fetchurl,
  callPackage,
}:

let

  pname = "lens-desktop";
  version = "2026.6.260931";

  sources = {
    aarch64-darwin = {
      hash = "sha512-eCE3w7NlYrHiexCirH2wFN0nOO3qAt5acbldXbDMVIrG94tbgM8Y5ZO8/YIUN45XbotYtKW8/Nw+WsrTp6DPBg==";
      url = "https://api.k8slens.dev/binaries/Lens-${version}-latest-arm64.dmg";
    };

    x86_64-linux = {
      hash = "sha512-P9PrtbGKaHNlzZsm10ovkYCBBfQpVWBgcVsYLETMwINP2bzrIIK5HVbkbcTEUsxK90L7MQmFwpAssojW0b9G5Q==";
      url = "https://api.k8slens.dev/binaries/Lens-${version}-latest.x86_64.AppImage";
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}")) url hash;
  };

  meta = {
    description = "Kubernetes IDE";
    homepage = "https://k8slens.dev/";
    license = lib.licenses.lens;

    maintainers = with lib.maintainers; [
      dbirks
      qweered
      RossComputerGuy
      starkca90
    ];

    platforms = builtins.attrNames sources;
  };

  updateScript = ./update.sh;

in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      src
      meta
      updateScript
      ;
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      src
      meta
      updateScript
      ;
  }
