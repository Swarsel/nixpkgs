{
  lib,
  fetchurl,
  autoreconfHook,
  callPackage,
  fetchpatch,
}:
let
  common = opts: callPackage (import ./common.nix opts) { };

  # Gets the OpenSSH mirror URL.
  urlFor = version: "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
in
{
  openssh = common rec {
    pname = "openssh";
    version = "10.3p1";

    src = fetchurl {
      url = urlFor version;
      hash = "sha256-VmgqNruS3PS08Bb9jsjnQFm3mo3iXBXWcNcx59GORfQ=";
    };

    extraMeta = {
      maintainers = with lib.maintainers; [
        das_j
        helsinki-Jo
        numinit
        philiptaron
      ];
    };

    extraPatches = [
      # Use ssh-keysign from PATH
      # ssh-keysign is used for host-based authentication, and is designed to be used
      # as SUID-root program. OpenSSH defaults to referencing it from libexec, which
      # cannot be made SUID in Nix.
      ./ssh-keysign-8.5.patch
    ];
  };

  openssh_gssapi = common rec {
    pname = "openssh-with-gssapi";
    version = "10.3p1";

    src = fetchurl {
      url = urlFor version;
      hash = "sha256-VmgqNruS3PS08Bb9jsjnQFm3mo3iXBXWcNcx59GORfQ=";
    };

    extraDesc = " with GSSAPI support";
    extraNativeBuildInputs = [ autoreconfHook ];

    extraPatches = [
      ./ssh-keysign-8.5.patch

      (fetchpatch {
        hash = "sha256-gs5Vw4f/TDxmme1DbrtgwvWcPGGmYIWE/A4JWa551zA=";
        name = "openssh-gssapi.patch";
        url = "https://salsa.debian.org/ssh-team/openssh/raw/debian/1%2510.3p1-1/debian/patches/gssapi.patch";
      })
    ];
  };

  openssh_hpn = common rec {
    pname = "openssh-with-hpn";
    version = "10.3p1";

    src = fetchurl {
      url = urlFor version;
      hash = "sha256-VmgqNruS3PS08Bb9jsjnQFm3mo3iXBXWcNcx59GORfQ=";
    };

    extraConfigureFlags = [ "--with-hpn" ];
    extraDesc = " with high performance networking patches";

    extraMeta = {
      maintainers = with lib.maintainers; [ abbe ];
    };

    extraNativeBuildInputs = [ autoreconfHook ];

    extraPatches =
      let
        urlBase = "https://raw.githubusercontent.com/freebsd/freebsd-ports/294be7ad9ef5106b696d830e06b9f322bd79d6f5/security/openssh-portable/files";
        noBlocklistdHpnGluePatch = "${urlBase}/extra-patch-no-blocklistd-hpn-glue";
        hpnPatch = "${urlBase}/extra-patch-hpn";
      in
      [
        ./ssh-keysign-8.5.patch

        # the blocklistd patch from FreeBSD ports is now required for HPN,
        # unless we apply this HPN glue patch
        (fetchpatch {
          extraPrefix = "";
          hash = "sha256-+AeJ9fLmmT/P07JZvGaXpNft+2F9PoFsbzr+s9wfdro=";
          name = "ssh-no-blocklistd-hpn-glue.patch";
          url = noBlocklistdHpnGluePatch;
        })

        # HPN Patch from FreeBSD ports
        (fetchpatch {
          excludes = [ "channels.c" ];
          hash = "sha256-dEYCSBcUXbSBzoMV/6QwLl5tj0c0/DPTtArchfRRQvM=";
          name = "ssh-hpn-wo-channels.patch";
          stripLen = 1;
          url = hpnPatch;
        })

        (fetchpatch {
          extraPrefix = "";
          hash = "sha256-pDLUbjv5XIyByEbiRAXC3WMUPKmn15af1stVmcvr7fE=";
          includes = [ "channels.c" ];
          name = "ssh-hpn-channels.patch";
          url = hpnPatch;
        })
      ];
  };
}
