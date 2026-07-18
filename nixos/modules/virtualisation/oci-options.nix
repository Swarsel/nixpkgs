{
  lib,
  ...
}:
{
  imports = [
    ./disk-size-option.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "oci"
        "diskSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options = {
    oci = {
      efi = lib.mkOption {
        default = true;

        description = ''
          Whether the OCI instance is using EFI.
        '';

        internal = true;
      };
    };
  };
}
