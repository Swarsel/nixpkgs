{
  lib,
  atk,
  buildFHSEnv,
  cairo,
  callPackage,
  cyrus_sasl,
  ffmpeg_7,
  gdk-pixbuf,
  gtk4,
  libepoxy,
  libxcb,
  libxi,
  pango,
  protobufc,
  wayland,
  webkitgtk_4_1,
  writeShellApplication,
}:

let
  workspacesclient = callPackage ./workspacesclient.nix { };

  # Source: https://github.com/jthomaschewski/pkgbuilds/pull/3
  # Credits to https://github.com/rwolfson
  custom_lsb_release = writeShellApplication {
    name = "lsb_release";

    text = ''
      # "Fake" lsb_release script
      # This only exists so that "lsb_release -r" will return the below string
      # when placed in the $PATH

      if [ "$#" -ne 1 ] || [ "$1" != "-r" ] ; then
          echo "Expected only '-r' argument"
          exit 1
      fi

      echo "Release: 22.04"
    '';
  };
in
buildFHSEnv {
  inherit (workspacesclient) version;
  pname = "aws-workspaces";

  extraBwrapArgs = [
    # provide certificates where Debian-style OpenSSL can find them
    "--symlink /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem"
  ];

  # expected executable doesn't match the name of this package
  extraInstallCommands = ''
    mv $out/bin/aws-workspaces $out/bin/${workspacesclient.meta.mainProgram}

    ln -s ${workspacesclient}/share $out/
  '';

  includeClosures = true;
  runScript = lib.getExe workspacesclient;

  targetPkgs = pkgs: [
    workspacesclient
    custom_lsb_release
    webkitgtk_4_1
    gtk4
    libepoxy
    libxcb
    libxi
    ffmpeg_7
    pango
    atk
    cairo
    gdk-pixbuf
    protobufc
    cyrus_sasl
    wayland
  ];

  meta = workspacesclient.meta;
}
