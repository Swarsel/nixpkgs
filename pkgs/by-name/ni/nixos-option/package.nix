{
  lib,
  coreutils,
  installShellFiles,
  jq,
  makeWrapper,
  man-db,
  nix,
  nixosTests,
  runCommand,
  shellcheck,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  src = ./nixos-option.sh;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  env = {
    nixosOptionManpage = "${placeholder "out"}/share/man";
    nixosOptionNix = "${./nixos-option.nix}";
  };

  installPhase = ''
    runHook preInstall

    install -Dm555 $src $out/bin/nixos-option
    substituteAllInPlace $out/bin/nixos-option
    installManPage ${./nixos-option.8}

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/nixos-option \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          jq
          man-db
          nix
        ]
      }
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;
  dontUnpack = true;
  name = "nixos-option";

  passthru.tests = {
    installer-simpleUefiSystemdBoot = nixosTests.installer.simpleUefiSystemdBoot;

    shellcheck = runCommand "nixos-option-shellchecked" { nativeBuildInputs = [ shellcheck ]; } ''
      shellcheck ${./nixos-option.sh} && touch $out
    '';
  };

  meta = {
    description = "Evaluate NixOS configuration and return the properties of given option";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      FireyFly
      azuwis
      aleksana
    ];

    mainProgram = "nixos-option";
  };
}
