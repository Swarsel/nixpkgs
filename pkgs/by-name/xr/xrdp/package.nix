{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  applyPatches,
  autoconf,
  automake,
  fuse3,
  gitUpdater,
  lame,
  libdrm,
  libjpeg,
  libjpeg_turbo,
  libopus,
  libtool,
  libx11,
  libxfixes,
  libxrandr,
  nasm,
  nixosTests,
  openssl,
  pam,
  perl,
  pixman,
  pkg-config,
  systemd,
  which,
  xauth,
  xorg-server,
}:

let
  xorgxrdp = stdenv.mkDerivation rec {
    pname = "xorgxrdp";
    version = "0.10.5";

    src = fetchFromGitHub {
      owner = "neutrinolabs";
      repo = "xorgxrdp";
      rev = "v${version}";
      hash = "sha256-P7mgdHIq7/Vkk5CR4mUYtQ0xBjh3J2QrYAobKbw1KXM=";
    };

    postPatch = ''
      # patch from Debian, allows to run xrdp daemon under unprivileged user
      substituteInPlace module/rdpClientCon.c \
        --replace 'g_sck_listen(dev->listen_sck);' 'g_sck_listen(dev->listen_sck); g_chmod_hex(dev->uds_data, 0x0660);'

      substituteInPlace configure.ac \
        --replace 'moduledir=`pkg-config xorg-server --variable=moduledir`' "moduledir=$out/lib/xorg/modules" \
        --replace 'sysconfdir="/etc"' "sysconfdir=$out/etc"
    '';

    nativeBuildInputs = [
      pkg-config
      autoconf
      automake
      which
      libtool
      nasm
    ];

    buildInputs = [
      xorg-server
      libdrm
    ];

    preConfigure = ''
      ./bootstrap
      export XRDP_CFLAGS="-I${xrdp.src}/common -I${libdrm.dev}/include -I${libdrm.dev}/include/libdrm"
    '';

    enableParallelBuilding = true;
    passthru.updateScript = gitUpdater { rev-prefix = "v"; };
  };

  xrdp = stdenv.mkDerivation rec {
    pname = "xrdp";
    version = "0.10.6";

    src = applyPatches {
      inherit version;
      name = "xrdp-patched-${version}";
      patches = [ ./dynamic_config.patch ];

      src = fetchFromGitHub {
        owner = "neutrinolabs";
        repo = "xrdp";
        rev = "v${version}";
        hash = "sha256-BoIpWafUWznRHN8BaZmld8vVbZtywaGiooGPnDtDCjM=";
        fetchSubmodules = true;
      };
    };

    postPatch = ''
      substituteInPlace sesman/sesexec/xauth.c --replace "xauth -q" "${xauth}/bin/xauth -q"

      substituteInPlace configure.ac --replace /usr/include/ ""
    '';

    nativeBuildInputs = [
      pkg-config
      autoconf
      automake
      which
      libtool
      nasm
      perl
    ];

    buildInputs = [
      fuse3
      lame
      libjpeg
      libjpeg_turbo
      libopus
      openssl
      pam
      pixman
      systemd
      libx11
      libxfixes
      libxrandr
    ];

    configureFlags = [
      "--with-systemdsystemunitdir=/var/empty"
      "--enable-fuse"
      "--enable-ipv6"
      "--enable-jpeg"
      "--enable-mp3lame"
      "--enable-opus"
      "--enable-pam-config=unix"
      "--enable-pixman"
      "--enable-rdpsndaudin"
      "--enable-rfxcodec"
      "--enable-tjpeg"
      "--enable-vsock"
    ];

    preConfigure = ''
      (cd librfxcodec && ./bootstrap && ./configure --prefix=$out --enable-static --disable-shared)
      ./bootstrap
    '';

    postInstall = ''
      # remove generated keys (as non-deterministic)
      rm $out/etc/xrdp/{rsakeys.ini,key.pem,cert.pem}

      cp $src/keygen/openssl.conf $out/share/xrdp/openssl.conf

      substituteInPlace $out/etc/xrdp/sesman.ini --replace-fail /etc/xrdp/pulse $out/etc/xrdp/pulse
      substituteInPlace $out/etc/xrdp/sesman.ini --replace-fail '#SessionSockdirGroup=xrdp' 'SessionSockdirGroup=xrdp'

      # remove all session types except Xorg (they are not supported by this setup)
      perl -i -ne 'print unless /\[(X11rdp|Xvnc|console|vnc-any|sesman-any|rdp-any|neutrinordp-any)\]/ .. /^$/' $out/etc/xrdp/xrdp.ini

      # remove all session types and then add Xorg
      perl -i -ne 'print unless /\[(X11rdp|Xvnc|Xorg)\]/ .. /^$/' $out/etc/xrdp/sesman.ini

      cat >> $out/etc/xrdp/sesman.ini <<EOF

      [Xorg]
      param=${xorg-server}/bin/Xorg
      param=-modulepath
      param=${xorgxrdp}/lib/xorg/modules,${xorg-server}/lib/xorg/modules
      param=-config
      param=${xorgxrdp}/etc/X11/xrdp/xorg.conf
      param=-noreset
      param=-nolisten
      param=tcp
      param=-logfile
      param=.xorgxrdp.%s.log
      EOF
    '';

    dontDisableStatic = true;
    enableParallelBuilding = true;

    installFlags = [
      "DESTDIR=$(out)"
      "prefix="
    ];

    passthru = {
      inherit xorgxrdp;

      tests = {
        inherit (nixosTests) xrdp;
      };

      updateScript = _experimental-update-script-combinators.sequence (
        map (item: item.command) [
          (gitUpdater {
            attrPath = "xrdp.src";
            ignoredVersions = [ "beta" ];
            rev-prefix = "v";
          })
          {
            command = [
              "rm"
              "update-git-commits.txt"
            ];
          }
          (gitUpdater {
            attrPath = "xrdp.xorgxrdp";
            rev-prefix = "v";
          })
        ]
      );
    };

    meta = {
      description = "Open source RDP server";
      homepage = "https://github.com/neutrinolabs/xrdp";
      license = lib.licenses.asl20;

      maintainers = with lib.maintainers; [
        chvp
      ];

      platforms = lib.platforms.linux;
    };
  };
in
xrdp
