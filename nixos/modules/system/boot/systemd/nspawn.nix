{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with utils.systemdUtils.unitOptions;
with utils.systemdUtils.lib;
with lib;

let
  cfg = config.systemd.nspawn;

  checkExec = checkUnitConfig "Exec" [
    (assertOnlyFields [
      "Boot"
      "ProcessTwo"
      "Parameters"
      "Environment"
      "User"
      "WorkingDirectory"
      "PivotRoot"
      "Capability"
      "DropCapability"
      "NoNewPrivileges"
      "KillSignal"
      "Personality"
      "MachineID"
      "PrivateUsers"
      "NotifyReady"
      "SystemCallFilter"
      "LimitCPU"
      "LimitFSIZE"
      "LimitDATA"
      "LimitSTACK"
      "LimitCORE"
      "LimitRSS"
      "LimitNOFILE"
      "LimitAS"
      "LimitNPROC"
      "LimitMEMLOCK"
      "LimitLOCKS"
      "LimitSIGPENDING"
      "LimitMSGQUEUE"
      "LimitNICE"
      "LimitRTPRIO"
      "LimitRTTIME"
      "OOMScoreAdjust"
      "CPUAffinity"
      "Hostname"
      "ResolvConf"
      "Timezone"
      "LinkJournal"
      "Ephemeral"
      "AmbientCapability"
    ])
    (assertValueOneOf "Boot" boolValues)
    (assertValueOneOf "ProcessTwo" boolValues)
    (assertValueOneOf "NotifyReady" boolValues)
  ];

  checkFiles = checkUnitConfig "Files" [
    (assertOnlyFields [
      "ReadOnly"
      "Volatile"
      "Bind"
      "BindReadOnly"
      "TemporaryFileSystem"
      "Overlay"
      "OverlayReadOnly"
      "PrivateUsersChown"
      "BindUser"
      "Inaccessible"
      "PrivateUsersOwnership"
    ])
    (assertValueOneOf "ReadOnly" boolValues)
    (assertValueOneOf "Volatile" (boolValues ++ [ "state" ]))
    (assertValueOneOf "PrivateUsersChown" boolValues)
    (assertValueOneOf "PrivateUsersOwnership" [
      "off"
      "chown"
      "map"
      "auto"
    ])
  ];

  checkNetwork = checkUnitConfig "Network" [
    (assertOnlyFields [
      "Private"
      "VirtualEthernet"
      "VirtualEthernetExtra"
      "Interface"
      "MACVLAN"
      "IPVLAN"
      "Bridge"
      "Zone"
      "Port"
    ])
    (assertValueOneOf "Private" boolValues)
    (assertValueOneOf "VirtualEthernet" boolValues)
  ];

  instanceOptions = {
    options = (getAttrs [ "enable" ] sharedOptions) // {
      execConfig = mkOption {
        default = { };

        description = ''
          Each attribute in this set specifies an option in the
          `[Exec]` section of this unit. See
          {manpage}`systemd.nspawn(5)` for details.
        '';

        example = {
          Parameters = "/bin/sh";
        };

        type = types.addCheck (types.attrsOf unitOption) checkExec;
      };

      filesConfig = mkOption {
        default = { };

        description = ''
          Each attribute in this set specifies an option in the
          `[Files]` section of this unit. See
          {manpage}`systemd.nspawn(5)` for details.
        '';

        example = {
          Bind = [ "/home/alice" ];
        };

        type = types.addCheck (types.attrsOf unitOption) checkFiles;
      };

      networkConfig = mkOption {
        default = { };

        description = ''
          Each attribute in this set specifies an option in the
          `[Network]` section of this unit. See
          {manpage}`systemd.nspawn(5)` for details.
        '';

        example = {
          Private = false;
        };

        type = types.addCheck (types.attrsOf unitOption) checkNetwork;
      };
    };

  };

  instanceToUnit =
    name: def:
    let
      base = {
        text = ''
          [Exec]
          ${attrsToSection def.execConfig}

          [Files]
          ${attrsToSection def.filesConfig}

          [Network]
          ${attrsToSection def.networkConfig}
        '';
      }
      // def;
    in
    base // { unit = makeUnit name base; };

in
{

  options = {

    systemd.nspawn = mkOption {
      default = { };
      description = "Definition of systemd-nspawn configurations.";
      type = with types; attrsOf (submodule instanceOptions);
    };

  };

  config =
    let
      units = mapAttrs' (
        n: v:
        let
          nspawnFile = "${n}.nspawn";
        in
        nameValuePair nspawnFile (instanceToUnit nspawnFile v)
      ) cfg;
    in
    mkMerge [
      (mkIf (cfg != { }) {
        environment.etc."systemd/nspawn".source = mkIf (cfg != { }) (generateUnits {
          inherit units;
          allowCollisions = false;
          type = "nspawn";
          upstreamUnits = [ ];
          upstreamWants = [ ];
        });
      })
      {
        systemd.services."systemd-nspawn@".environment = {
          SYSTEMD_NSPAWN_UNIFIED_HIERARCHY = mkDefault "1";
        };

        systemd.targets.multi-user.wants = [ "machines.target" ];
      }
    ];
}
