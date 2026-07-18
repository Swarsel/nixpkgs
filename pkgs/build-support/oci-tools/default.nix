{
  lib,
  runCommand,
  writeClosure,
  writeText,
}:

{
  buildContainer =
    {
      args,
      arch ? "x86_64",
      mounts ? { },
      os ? "linux",
      readonly ? false,
    }:
    let
      sysMounts = {
        "/dev" = {
          options = [
            "nosuid"
            "strictatime"
            "mode=755"
            "size=65536k"
          ];

          source = "tmpfs";
          type = "tmpfs";
        };

        "/dev/mqueue" = {
          options = [
            "nosuid"
            "noexec"
            "nodev"
          ];

          source = "mqueue";
          type = "mqueue";
        };

        "/dev/pts" = {
          options = [
            "nosuid"
            "noexec"
            "newinstance"
            "ptmxmode=0666"
            "mode=755"
            "gid=5"
          ];

          source = "devpts";
          type = "devpts";
        };

        "/dev/shm" = {
          options = [
            "nosuid"
            "noexec"
            "nodev"
            "mode=1777"
            "size=65536k"
          ];

          source = "shm";
          type = "tmpfs";
        };

        "/proc" = {
          source = "proc";
          type = "proc";
        };

        "/sys" = {
          options = [
            "nosuid"
            "noexec"
            "nodev"
            "ro"
          ];

          source = "sysfs";
          type = "sysfs";
        };

        "/sys/fs/cgroup" = {
          options = [
            "nosuid"
            "noexec"
            "nodev"
            "relatime"
            "ro"
          ];

          source = "cgroup";
          type = "cgroup";
        };
      };
      config = writeText "config.json" (
        builtins.toJSON {
          linux = {
            namespaces = map (type: { inherit type; }) [
              "pid"
              "network"
              "mount"
              "ipc"
              "uts"
            ];
          };

          mounts = lib.mapAttrsToList (
            destination:
            {
              source,
              type,
              options ? null,
            }:
            {
              inherit
                destination
                type
                source
                options
                ;
            }
          ) sysMounts;

          ociVersion = "1.0.0";

          platform = {
            inherit os arch;
          };

          process = {
            inherit args;
            cwd = "/";

            user = {
              gid = 0;
              uid = 0;
            };
          };

          root = {
            inherit readonly;
            path = "rootfs";
          };
        }
      );
    in
    runCommand "join" { } ''
      set -o pipefail
      mkdir -p $out/rootfs/{dev,proc,sys}
      cp ${config} $out/config.json
      xargs tar c < ${writeClosure args} | tar -xC $out/rootfs/
    '';
}
