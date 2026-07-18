{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  callPackage,
  copyDesktopItems,
  ffmpeg,
  jq,
  kdePackages,
  libmediainfo,
  libusb1,
  libx11,
  makeDesktopItem,
  openssl,
  p7zip,
  socat,
  systemdLibs,
  vapoursynth,
  writeShellScriptBin,
}:
let
  mpvForSVP = callPackage ./mpv.nix { };

  # Script provided by GitHub user @xrun1
  # https://github.com/xddxdd/nur-packages/issues/31#issuecomment-1812591688
  fakeLsof = writeShellScriptBin "lsof" ''
    for arg in "$@"; do
      if [ -S "$arg" ]; then
        printf %s p
        echo '{"command": ["get_property", "pid"]}' |
          ${socat}/bin/socat - "UNIX-CONNECT:$arg" |
          ${jq}/bin/jq -Mr .data
        printf '\n'
      fi
    done
  '';

  # SVP expects findmnt to return path to storage device for software protection.
  # Workaround for tmp-as-root and encrypted root use cases, by returning first storage device on system.
  fakeFindmnt = writeShellScriptBin "findmnt" ''
    find /dev/ -name 'nvme*n*p*' -or -name 'sd*' -or -name 'vd*' 2>/dev/null | sort | head -n1
  '';

  libraries = [
    mpvForSVP
    fakeLsof
    fakeFindmnt
    (lib.getLib stdenv.cc.cc)
    kdePackages.qtbase
    kdePackages.qtdeclarative
    ffmpeg.bin
    libmediainfo
    libusb1
    vapoursynth
    libx11
    systemdLibs
    openssl
  ];

  svp-dist = stdenv.mkDerivation (finalAttrs: {
    pname = "svp-dist";
    version = "4.7.305";

    src = fetchurl {
      url = "https://www.svp-team.com/files/svp4-linux.${finalAttrs.version}.tar.bz2";
      hash = "sha256-PWAcm/hIA4JH2QtJPP+gSJdJLRdfdbZXIVdWELazbxQ=";
    };

    nativeBuildInputs = [
      p7zip
    ];

    buildPhase = ''
      mkdir installer
      LANG=C grep --only-matching --byte-offset --binary --text  $'7z\xBC\xAF\x27\x1C' "svp4-linux.run" |
        cut -f1 -d: |
        while read ofs; do dd if="svp4-linux.run" bs=1M iflag=skip_bytes status=none skip=$ofs of="installer/bin-$ofs.7z"; done
    '';

    installPhase = ''
      mkdir -p $out/opt
      for f in "installer/"*.7z; do
        7z -bd -bb0 -y x -o"$out/opt/" "$f" || true
      done

      for SIZE in 32 48 64 128; do
        mkdir -p "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps"
        mv "$out/opt/svp-manager4-''${SIZE}.png" "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/svp-manager4.png"
      done
      rm -f $out/opt/{add,remove}-menuitem.sh
    '';

    dontFixup = true;

    unpackPhase = ''
      tar xf ${finalAttrs.src}
    '';
  });

  fhs = buildFHSEnv {
    inherit (svp-dist) version;
    pname = "SVPManager";
    runScript = "${svp-dist}/opt/SVPManager";
    targetPkgs = pkgs: libraries;
    unshareCgroup = false;
    unshareIpc = false;
    unshareNet = false;
    unsharePid = false;
    unshareUser = false;
    unshareUts = false;
  };
in
stdenv.mkDerivation {
  inherit (svp-dist) version;
  pname = "svp";
  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    mkdir -p $out/bin $out/share
    ln -s ${fhs}/bin/SVPManager $out/bin/SVPManager
    ln -s ${svp-dist}/share/icons $out/share/icons
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Player"
        "Video"
      ];

      desktopName = "SVP 4 Linux";
      exec = "${fhs}/bin/SVPManager %f";
      genericName = "Real time frame interpolation";
      icon = "svp-manager4";

      mimeTypes = [
        "video/x-msvideo"
        "video/x-matroska"
        "video/webm"
        "video/mpeg"
        "video/mp4"
      ];

      name = "svp-manager4";
      startupNotify = true;
      terminal = false;
    })
  ];

  dontUnpack = true;
  passthru.mpv = mpvForSVP;

  meta = {
    description = "SmoothVideo Project 4 (SVP4) converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player";
    homepage = "https://www.svp-team.com/wiki/SVP:Linux";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "SVPManager";
  };
}
