{
  lib,
  coreutils,
  findutils,
  gnugrep,
  makeWrapper,
  src,
  stdenvNoCC,
  systemd,
  version,
}:

stdenvNoCC.mkDerivation {
  inherit src version;

  patches = [
    ./nixos-generator.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D -m 0555 distrobuilder/lxc.generator $out/lib/systemd/system-generators/lxc
    wrapProgram $out/lib/systemd/system-generators/lxc --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        findutils
        gnugrep
        systemd
      ]
    }:${systemd}/lib/systemd
  '';

  dontBuild = true;
  name = "distrobuilder-nixos-generator";
}
