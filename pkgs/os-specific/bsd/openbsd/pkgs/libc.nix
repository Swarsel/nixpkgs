{
  lib,
  libcMinimal,
  libexecinfo,
  libkvm,
  libm,
  librpcsvc,
  librthread,
  libutil,
  rtld,
  stdenvNoLibc,
  symlinkJoin,
  version,
}:

symlinkJoin {
  inherit version;
  pname = "libc-openbsd";

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postBuild = ''
    rm -r "$out/nix-support"
    mkdir -p "$man/share/man"
    mv "$out/share"/man* "$man/share/man"
    rmdir "$out/share"
    fixupPhase
  '';

  paths =
    lib.concatMap
      (p: [
        (lib.getDev p)
        (lib.getLib p)
        (lib.getMan p)
      ])
      (
        [
          libcMinimal
          libm
          librthread
          librpcsvc
          libutil
          libexecinfo
          libkvm
        ]
        ++ (lib.optional (!stdenvNoLibc.hostPlatform.isStatic) rtld)
      );

  meta.platforms = lib.platforms.openbsd;
}
