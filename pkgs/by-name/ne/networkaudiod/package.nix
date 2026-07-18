{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  dpkg,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";
in
stdenv.mkDerivation rec {
  pname = "networkaudiod";
  version = "4.1.1-46";

  src =
    {
      aarch64-linux = fetchurl {
        sha256 = "sha256-fjSCWX9VYhVJ43N2kSqd5gfTtDJ1UiH4j5PJ9I5Skag=";
        url = "https://www.signalyst.eu/bins/naa/linux/buster/${pname}_${version}_arm64.deb";
      };

      x86_64-linux = fetchurl {
        sha256 = "sha256-un5VcCnvCCS/KWtW991Rt9vz3flYilERmRNooEsKCkA=";
        url = "https://www.signalyst.eu/bins/naa/linux/buster/${pname}_${version}_amd64.deb";
      };
    }
    .${system} or throwSystem;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    alsa-lib
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    # main executable
    mkdir -p $out/bin
    cp ./usr/sbin/networkaudiod $out/bin

    # systemd service file
    mkdir -p $out/lib/systemd/system
    cp ./lib/systemd/system/networkaudiod.service $out/lib/systemd/system

    # documentation
    mkdir -p $out/share/doc/networkaudiod
    cp -r ./usr/share/doc/networkaudiod $out/share/doc/

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/lib/systemd/system/networkaudiod.service \
      --replace /usr/sbin/networkaudiod $out/bin/networkaudiod
  '';

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg -x $src .
  '';

  meta = {
    description = "Network Audio Adapter daemon";
    homepage = "https://www.signalyst.com/index.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    mainProgram = "networkaudiod";
  };
}
