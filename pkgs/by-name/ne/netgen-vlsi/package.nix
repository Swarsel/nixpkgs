{
  lib,
  stdenv,
  fetchFromGitHub,
  m4,
  nix-update-script,
  tcl,
  tk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netgen";
  version = "1.5.323";

  src = fetchFromGitHub {
    owner = "RTimothyEdwards";
    repo = "netgen";
    tag = finalAttrs.version;
    hash = "sha256-L8DJdk5lkb/qh5GbZK9eDNq1eZPEQq4ZZsBQPDJcKJ0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    m4
  ];

  buildInputs = [
    tcl
    tk
  ];

  configureFlags = [
    "--with-tcl=${lib.getLib tcl}/lib"
    "--with-tk=${lib.getLib tk}/lib"
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu89";

  # Netgen generates a wrapper script with a hardcoded /bin/bash shebang.
  # We fix it here because patchShebangs sometimes misses it in post-install.
  postFixup = ''
    sed -i "1s|#!/bin/bash|#!${stdenv.shell}|" $out/bin/netgen
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "LVS tool for VLSI circuit netlists";
    homepage = "https://github.com/RTimothyEdwards/netgen";
    license = lib.licenses.gpl1Only;
    maintainers = [ lib.maintainers.gonsolo ];
    mainProgram = "netgen";
  };
})
