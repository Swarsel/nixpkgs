{
  lib,
  apple-sdk_26,
  libutil,
  mkAppleDerivation,
  pkg-config,
}:

mkAppleDerivation {
  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Use `scandir` on versions of macOS older than 26.4.
    ./patches/0001-Fall-back-to-scandir.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    apple-sdk_26
    libutil
  ];

  releaseName = "patch_cmds";
  xcodeHash = "sha256-Ox8Ii2sUuledUttZ64DaHC0iFlUybs3lNZ23IDeziPM=";

  meta = {
    description = "BSD patch commands for Darwin";

    license = [
      lib.licenses.apple-psl10
      lib.licenses.bsd2 # -freebsd
      lib.licenses.bsd3
      lib.licenses.bsdOriginal
    ];
  };
}
