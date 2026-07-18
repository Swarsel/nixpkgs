{
  lib,
  stdenv,
  makeShellWrapper,
  pkgsBuildBuild,
  runCommand,
  rustc,
  ...
}:

runCommand "${stdenv.targetPlatform.config}-cargo-${lib.getVersion pkgsBuildBuild.cargo}"
  {
    inherit (pkgsBuildBuild.cargo) meta;
    # Use depsBuildBuild or it tries to use target-runtimeShell
    depsBuildBuild = [ makeShellWrapper ];
  }
  ''
    mkdir -p $out/bin
    ln -s ${pkgsBuildBuild.cargo}/share $out/share

    makeWrapper "${pkgsBuildBuild.cargo}/bin/cargo" "$out/bin/cargo" \
      --prefix PATH : "${rustc}/bin"
  ''
