{
  lib,
  i18n_module,
  libcMinimal,
  libcrypt,
  libm,
  libpthread,
  libresolv,
  librpcsvc,
  librt,
  libutil,
  symlinkJoin,
  version,
}:

symlinkJoin {
  inherit version;
  pname = "libc-netbsd";

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postBuild = ''
    rm -r "$out/nix-support"
    fixupPhase
  '';

  paths =
    lib.concatMap
      (p: [
        (lib.getDev p)
        (lib.getLib p)
        (lib.getMan p)
      ])
      [
        libcMinimal
        libm
        libpthread
        libresolv
        librpcsvc
        i18n_module
        libutil
        librt
        libcrypt
      ];

  meta.platforms = lib.platforms.netbsd;
}
