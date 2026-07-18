{
  lib,
  fetchurl,
  autoPatchelfHook,
  buildFHSEnv,
  dpkg,
  inotify-tools,
  stdenvNoCC,
  sysctl,
  writeScript,
}:

let
  pname = "expressvpn";
  clientVersion = "3.52.0";
  clientBuild = "2";
  version = lib.strings.concatStringsSep "." [
    clientVersion
    clientBuild
  ];

  expressvpnBase = stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://www.expressvpn.works/clients/linux/expressvpn_${version}-1_amd64.deb";
      hash = "sha256-cDZ9R+MA3FXEto518bH4/c1X4W9XxgTvXns7zisylew=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
    ];

    installPhase = ''
      runHook preInstall
      mv usr/ $out/
      runHook postInstall
    '';

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg --fsys-tarfile $src | tar --extract
      runHook postUnpack
    '';
  };

  expressvpndFHS = buildFHSEnv {
    inherit version;
    pname = "expressvpnd";

    # expressvpnd binary has hard-coded the path /sbin/sysctl hence below workaround.
    extraBuildCommands = ''
      mkdir -p sbin
      chmod +w sbin
      ln -s ${sysctl}/bin/sysctl sbin/sysctl
    '';

    # When connected, it directly creates/deletes resolv.conf to change the DNS entries.
    # Since it's running in an FHS environment, it has no effect on actual resolv.conf.
    # Hence, place a watcher that updates host resolv.conf when FHS resolv.conf changes.
    # Mount the host's resolv.conf to the container's /etc/resolv.conf
    runScript = writeScript "${pname}-wrapper" ''
      mkdir -p /host/etc
      [ -e /host/etc/resolv.conf ] || touch /host/etc/resolv.conf
      mount --bind /etc/resolv.conf /host/etc/resolv.conf
      mount -o remount,rw /host/etc/resolv.conf
      trap "umount /host/etc/resolv.conf" EXIT

      while inotifywait /etc 2>/dev/null;
      do
        cp /etc/resolv.conf /host/etc/resolv.conf;
      done &
      expressvpnd --client-version ${clientVersion} --client-build ${clientBuild}
    '';

    # The expressvpnd binary also uses hard-coded paths to the other binaries and files
    # it ships with, hence the FHS environment.
    targetPkgs =
      pkgs: with pkgs; [
        expressvpnBase
        inotify-tools
        iproute2
      ];
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    ln -s ${expressvpnBase}/bin/expressvpn $out/bin
    ln -s ${expressvpndFHS}/bin/expressvpnd $out/bin
    ln -s ${expressvpnBase}/share/{bash-completion,doc,man} $out/share/
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  meta = {
    description = "CLI client for ExpressVPN";
    homepage = "https://www.expressvpn.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ yureien ];
    platforms = [ "x86_64-linux" ];
  };
}
