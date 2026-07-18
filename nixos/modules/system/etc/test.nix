{
  lib,
  coreutils,
  evalMinimalConfig,
  fakechroot,
  fakeroot,
  pkgsModule,
  runCommand,
  util-linux,
  vmTools,
  writeText,
}:
let
  node = evalMinimalConfig (
    { config, ... }:
    {
      imports = [
        pkgsModule
        ../etc/etc.nix
      ];

      environment.etc."hosts" = {
        mode = "0751";
        text = hostsText;
      };

      environment.etc."passwd" = {
        text = passwdText;
      };
    }
  );
  passwdText = ''
    root:x:0:0:System administrator:/root:/run/current-system/sw/bin/bash
  '';
  hostsText = ''
    127.0.0.1 localhost
    ::1 localhost
    # testing...
  '';
in
lib.recurseIntoAttrs {
  # fakeroot is behaving weird
  test-etc-fakeroot =
    runCommand "test-etc"
      {
        fakeRootCommands = ''
          mkdir -p /etc
          ${node.config.system.build.etcActivationCommands}
          diff /etc/hosts ${writeText "expected-hosts" hostsText}
          touch $out
        '';

        nativeBuildInputs = [
          fakeroot
          fakechroot
          # for chroot
          coreutils
          # fakechroot needs getopt, which is provided by util-linux
          util-linux
        ];
      }
      ''
        mkdir fake-root
        export FAKECHROOT_EXCLUDE_PATH=/dev:/proc:/sys:${builtins.storeDir}:$out
        if [ -e "$NIX_ATTRS_SH_FILE" ]; then
          export FAKECHROOT_EXCLUDE_PATH=$FAKECHROOT_EXCLUDE_PATH:$NIX_ATTRS_SH_FILE
        fi
        fakechroot fakeroot chroot $PWD/fake-root bash -e -c '
          if [ -e "$NIX_ATTRS_SH_FILE" ]; then . "$NIX_ATTRS_SH_FILE"; fi
          source $stdenv/setup
          eval "$fakeRootCommands"
        '
      '';

  test-etc-vm = vmTools.runInLinuxVM (
    runCommand "test-etc-vm" { } ''
      mkdir -p /etc
      ${node.config.system.build.etcActivationCommands}
      set -x
      [[ -L /etc/passwd ]]
      diff /etc/passwd ${writeText "expected-passwd" passwdText}
      [[ 751 = $(stat --format %a /etc/hosts) ]]
      diff /etc/hosts ${writeText "expected-hosts" hostsText}
      set +x
      touch $out
    ''
  );

}
