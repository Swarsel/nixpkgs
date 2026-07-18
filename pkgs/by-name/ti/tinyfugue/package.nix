{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  ncurses,
  openssl,
  pcre2,
  zlib,
  sslSupport ? true,
}:

assert sslSupport -> openssl != null;

let
  inherit (lib)
    licenses
    maintainers
    optional
    platforms
    ;
in

stdenv.mkDerivation rec {
  pname = "tinyfugue";
  version = "50b8";

  src = fetchurl {
    url = "mirror://sourceforge/project/tinyfugue/tinyfugue/${verUrl}/tf-${version}.tar.gz";
    sha256 = "12fra2fdwqj6ilv9wdkc33rkj343rdcf5jyff4yiwywlrwaa2l1p";
  };

  patches = [
    ./fix-build.patch
    (fetchpatch {
      hash = "sha256-Ge6545PCgcvnSgtDChqUQgf6b3BMjNveBAxQ8fAy8f4=";
      url = "https://src.fedoraproject.org/rpms/tinyfugue/raw/ce016e8fb60a51de7c9d0c45dad109b3809de048/f/tinyfigue-configure-c99.patch";
    })
    (fetchpatch {
      hash = "sha256-T0XiadrviyuvtZZKYG/kXHQSC7RZkLKQGHOMrnfyLVg=";
      url = "https://src.fedoraproject.org/rpms/tinyfugue/raw/ce016e8fb60a51de7c9d0c45dad109b3809de048/f/tf-50b8.pcre.patch";
    })
    (fetchpatch {
      hash = "sha256-pTtCUwMBk+t4lK0Z1fKPKaQemdpEdVPe2NScpD8QBS8=";
      url = "https://src.fedoraproject.org/rpms/tinyfugue/raw/ce016e8fb60a51de7c9d0c45dad109b3809de048/f/tf-50b8-pcre2.patch";
    })
  ];

  postPatch = ''
    # remove bundled old PCRE
    rm -rv src/pcre-2.08
  '';

  buildInputs = [
    ncurses
    pcre2
    zlib
  ]
  ++ optional sslSupport openssl;

  configureFlags = optional (!sslSupport) "--disable-ssl";
  # Workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: world.o:/build/tf-50b8/src/socket.h:24: multiple definition of
  #     `world_decl'; command.o:/build/tf-50b8/src/socket.h:24: first defined here
  env.NIX_CFLAGS_COMPILE = "-fcommon -Wno-incompatible-pointer-types -Wno-return-mismatch";
  verUrl = "5.0%20beta%208";

  meta = {
    description = "Terminal UI, screen-oriented MUD client";

    longDescription = ''
      TinyFugue, aka "tf", is a flexible, screen-oriented MUD client, for use
      with any type of text MUD.
    '';

    homepage = "https://tinyfugue.sourceforge.net/";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.KibaFox ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "tf";
  };
}
