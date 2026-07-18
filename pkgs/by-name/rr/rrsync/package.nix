{
  stdenv,
  python3,
  rsync,
}:

stdenv.mkDerivation {
  inherit (rsync) version src;
  inherit (rsync) patches;
  pname = "rrsync";

  postPatch = ''
    substituteInPlace support/rrsync --replace /usr/bin/rsync ${rsync}/bin/rsync
  '';

  buildInputs = [
    rsync
    (python3.withPackages (pythonPackages: with pythonPackages; [ braceexpand ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp support/rrsync $out/bin
    chmod a+x $out/bin/rrsync
  '';

  dontBuild = true;
  # Skip configure and build phases.
  # We just want something from the support directory
  dontConfigure = true;

  meta = rsync.meta // {
    description = "Helper to run rsync-only environments from ssh-logins";
    mainProgram = "rrsync";
  };
}
