{
  lib,
  stdenv,
  bash,
  coreutils,
  darwin,
  findutils,
  gnugrep,
  shellcheck,
  # Avoid having GHC in the build-time closure of all NixOS configurations
  doCheck ? false,
}:

stdenv.mkDerivation {
  inherit doCheck;
  src = ./info.sh;
  strictDeps = true;
  buildInputs = [ bash ];

  buildPhase = ''
    substituteAllInPlace ./nix-info
  '';

  nativeCheckInputs = [ shellcheck ];

  checkPhase = ''
    shellcheck ./nix-info
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./nix-info $out/bin/nix-info
  '';

  is_darwin = lib.boolToYesNo stdenv.hostPlatform.isDarwin;
  multiusertest = ./multiuser.nix;
  name = "nix-info";

  path = lib.makeBinPath (
    [
      coreutils
      findutils
      gnugrep
    ]
    ++ (lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ])
  );

  preferLocalBuild = true;
  relaxedsandboxtest = ./relaxedsandbox.nix;
  sandboxtest = ./sandbox.nix;

  unpackCmd = ''
    mkdir nix-info
    cp $src ./nix-info/nix-info
  '';

  meta = {
    platforms = lib.platforms.all;
  };
}
