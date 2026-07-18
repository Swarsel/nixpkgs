{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  stdenv = stdenvNoCC;

  pname = "ookla-speedtest";
  version = "1.2.0";

  srcs = {
    aarch64-darwin = fetchurl {
      sha256 = "sha256-yfgZIUnryI+GmZmM7Ksc4UQUQEWQfs5vU89Qh39N5m8=";
      url = "https://install.speedtest.net/app/cli/${pname}-${version}-macosx-universal.tgz";
    };

    aarch64-linux = fetchurl {
      sha256 = "sha256-OVPSMdo3g+K/iQS23XJ2fFxuUz4WPTdC/QQ3r/pDG9M=";
      url = "https://install.speedtest.net/app/cli/${pname}-${version}-linux-aarch64.tgz";
    };

    armv7l-linux = fetchurl {
      sha256 = "sha256-5F/N672KGFVTU1Uz3QMtaxC8jGTu5BObEUe5wJg10I0=";
      url = "https://install.speedtest.net/app/cli/${pname}-${version}-linux-armhf.tgz";
    };

    i686-linux = fetchurl {
      sha256 = "sha256-n/fhjbrn7g4DxmEIRFovts7qbIb2ZILhOS9ViBt3L+g=";
      url = "https://install.speedtest.net/app/cli/${pname}-${version}-linux-i386.tgz";
    };

    x86_64-linux = fetchurl {
      sha256 = "sha256-VpBZbFT/m+1j+jcy+BigXbwtsZrTbtaPIcpfZNXP7rc=";
      url = "https://install.speedtest.net/app/cli/${pname}-${version}-linux-x86_64.tgz";
    };
  };
in

stdenv.mkDerivation {
  inherit pname version;

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  outputs = [
    "out"
    "man"
  ];

  installPhase = ''
    install -D speedtest $out/bin/speedtest
    install -D speedtest.5 $man/share/man/man5/speedtest.5
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  meta = {
    description = "Command line internet speedtest tool by Ookla";
    homepage = "https://www.speedtest.net/apps/cli";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kranzes ];
    platforms = lib.attrNames srcs;
    mainProgram = "speedtest";
  };
}
