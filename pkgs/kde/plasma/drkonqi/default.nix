{
  elfutils,
  gdb,
  mkKdeDerivation,
  pkg-config,
  python3,
  replaceVars,
  systemd,
}:
let
  gdb' = gdb.override {
    hostCpuOnly = true;

    python3 = python3.withPackages (ps: [
      ps.psutil
      ps.pygdbmi
      ps.sentry-sdk
    ]);
  };
in
mkKdeDerivation {
  pname = "drkonqi";

  patches = [
    (replaceVars ./hardcode-paths.patch {
      eu-unstrip = "${elfutils}/bin/eu-unstrip";
      gdb = "${gdb'}/bin/gdb";
    })
  ];

  # Hardcoded as QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${gdb'}" > $out/nix-support/depends
  '';

  extraBuildInputs = [ systemd ];

  extraCmakeFlags = [
    "-DWITH_GDB12=1"
    "-DWITH_PYTHON_VENDORING=0"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
