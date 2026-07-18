{
  config,
  lib,
  pkgs,
  ...
}:

{

  imports = [
    ./options.nix
    ./systemd.nix
  ];

  config = lib.modules.mkIf config.services.hylafax.enable {
    assertions = [
      {
        assertion = config.services.hylafax.modems != { };

        message = ''
          HylaFAX cannot be used without modems.
          Please define at least one modem with
          <option>config.services.hylafax.modems</option>.
        '';
      }
    ];

    environment.systemPackages = [ config.services.hylafax.package ];

    users.users.uucp = {
      inherit (config.users.users.nobody) home;
      description = "Unix-to-Unix CoPy system";
      group = "uucp";
      isSystemUser = true;
      uid = config.ids.uids.uucp;
    };
  };

  meta.maintainers = [ lib.maintainers.yarny ];

}
