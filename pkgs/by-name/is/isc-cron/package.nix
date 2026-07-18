{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  replaceVars,
  vim,
  sendmailPath ? "/usr/sbin/sendmail",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cron";
  version = "4.1";

  src = fetchurl {
    url = "ftp://ftp.isc.org/isc/cron/cron_${finalAttrs.version}.shar";
    hash = "sha256-xEWDd1b7mI8slduNxV15N9FLygzfopLegTIsolVuw5o=";
  };

  patches = [
    (replaceVars ./0000-nixpkgs-specific.diff {
      inherit sendmailPath;

      defPath = lib.concatStringsSep ":" [
        "/run/wrappers/bin"
        "/nix/var/nix/profiles/default/bin"
        "/run/current-system/sw/bin"
        "/usr/bin"
        "/bin"
      ];

      viPath = lib.getExe' vim "vim";
    })
    # Fix build with gcc 15
    (fetchpatch {
      hash = "sha256-d1vN3TGAAOMlWpMZKnHU/RlZ5pBOl3+IXjZ4UALVqLI=";
      url = "https://github.com/vixie/cron/commit/3ce0c3acdf086a82638818635961c70cba2b6ba7.patch";
    })
  ];

  # do not set sticky bit in /nix/store
  # further, do not strip during install since it breaks on cross-compilation
  # and we will do this ourselves as needed
  postPatch = ''
    substituteInPlace Makefile \
      --replace ' -o root' ' ' \
      --replace 111 755 \
      --replace 4755 0755 \
      --replace ' -s cron' ' cron'
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "DESTROOT=$(out)"
  ];

  preInstall = ''
    mkdir -p $out/{{,s}bin,share/man/man{1,5,8}}
  '';

  unpackCmd = ''
    mkdir cron
    pushd cron
    sh $curSrc
    popd
  '';

  meta = {
    description = "Daemon for running commands at specific times";
    homepage = "https://ftp.isc.org/isc/cron/";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "cron";
  };
})
