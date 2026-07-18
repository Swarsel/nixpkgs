{
  lib,
  stdenv,
  fetchFromGitHub,
  # Optional, Jitsi still runs without, but you may pass null:
  alsa-lib,
  ant,
  dbus,
  gtk2,
  jdk8,
  libpulseaudio,
  libx11,
  libxext,
  libxscrnsaver,
  libxv,
  makeDesktopItem,
  openssl,
  unzip,
}:

let
  jdk = jdk8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jitsi";
  version = "2.11.5633";

  src = fetchFromGitHub {
    owner = "jitsi";
    repo = "jitsi";
    tag = lib.versions.patch finalAttrs.version;
    hash = "sha256-CN4o0VfHdoUteI2wyJ2hFJ9UsQ2wWUzcvrLMbR/l36M=";
  };

  patches = [ ./jitsi.patch ];
  nativeBuildInputs = [ unzip ];

  buildInputs = [
    ant
    jdk
  ];

  buildPhase = "ant make";

  installPhase = ''
    mkdir -p $out
    cp -a lib $out/
    rm -rf $out/lib/native/solaris
    cp -a sc-bundles $out/
    mkdir $out/bin
    cp resources/install/generic/run.sh $out/bin/jitsi
    chmod +x $out/bin/jitsi
    substituteInPlace $out/bin/jitsi \
      --subst-var-by JAVA ${jdk}/bin/java \
      --subst-var-by EXTRALIBS ${gtk2.out}/lib
    sed -e 's,^java\ ,${jdk}/bin/java ,' -i $out/bin/jitsi
    patchShebangs $out
    libPath="$libPath:${jdk.home}/lib/${jdk.architecture}"
    find $out/ -type f -name '*.so' | while read file; do
      patchelf --set-rpath "$libPath" "$file" && \
          patchelf --shrink-rpath "$file"
    done
  '';

  jitsiItem = makeDesktopItem {
    categories = [ "Chat" ];
    comment = "VoIP and Instant Messaging client";
    desktopName = "Jitsi";
    exec = "jitsi";
    genericName = "Instant Messaging";
    name = "Jitsi";
  };

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc # For libstdc++.
    alsa-lib
    dbus
    gtk2
    libpulseaudio
    openssl
    libx11
    libxext
    libxscrnsaver
    libxv
  ];

  meta = {
    description = "Open Source Video Calls and Chat";
    homepage = "https://desktop.jitsi.org/";
    license = lib.licenses.lgpl21Plus;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    platforms = lib.platforms.linux;
    mainProgram = "jitsi";
    teams = [ lib.teams.jitsi ];
  };
})
