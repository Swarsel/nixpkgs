{
  lib,
  binlore,
  buildEnv,
  man,
  nixos,
  nixos-enter,
  nixos-install,
  # TODO: replace indirect self-reference by proper self-reference
  #       https://github.com/NixOS/nixpkgs/pull/119942
  nixos-install-tools,
  nixosTests,
  runCommand,
}:
let
  inherit (nixos { }) config;
  version = config.system.nixos.version;
in
(buildEnv {
  extraOutputsToInstall = [ "man" ];
  name = "nixos-install-tools-${version}";

  paths = lib.attrValues {
    # See nixos/modules/installer/tools/tools.nix
    inherit (config.system.build) nixos-generate-config;
    inherit nixos-install nixos-enter;
    inherit (config.system.build.manual) nixos-configuration-reference-manpage;
  };

  # no documented flags show signs of exec; skim of source suggests
  # it's just --help execing man
  passthru.binlore.out = binlore.synthesize nixos-install-tools ''
    execer cannot bin/nixos-generate-config
  '';

  passthru.tests = {
    nixos-install-help =
      runCommand "test-nixos-install-help"
        {
          nativeBuildInputs = [
            man
            nixos-install-tools
          ];

          meta.description = ''
            Make sure that --help works. It's somewhat non-trivial because it
            requires man.
          '';
        }
        ''
          nixos-install --help | grep -F "System Manager's Manual"
          nixos-install --help | grep -F 'configuration.nix'
          nixos-generate-config --help | grep -F "System Manager's Manual"
          nixos-generate-config --help | grep -F 'hardware-configuration.nix'

          # FIXME: Tries to call unshare, which it must not do for --help
          # nixos-enter --help | grep -F 'NixOS Reference Pages'

          touch $out
        '';

    nixos-tests = lib.recurseIntoAttrs nixosTests.installer;
  };

  meta = {
    description = "Essential commands from the NixOS installer as a package";

    longDescription = ''
      With this package, you get the commands like nixos-generate-config and
      nixos-install that you would otherwise only find on a NixOS system, such
      as an installer image.

      This way, you can install NixOS using a machine that only has Nix.
    '';

    homepage = "https://nixos.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}).overrideAttrs
  {
    inherit version;
    pname = "nixos-install-tools";
  }
