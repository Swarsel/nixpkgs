{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.trivial) isFloat isInt isBool;
  inherit (lib.modules) mkIf;
  inherit (lib.options)
    literalExpression
    mkOption
    mkPackageOption
    mkEnableOption
    ;
  inherit (lib.strings)
    isString
    escapeShellArg
    escapeShellArgs
    concatMapStringsSep
    concatMapAttrsStringSep
    replaceStrings
    substring
    stringLength
    hasInfix
    hasSuffix
    typeOf
    match
    ;
  inherit (lib.lists)
    all
    isList
    head
    tail
    flatten
    foldl'
    ;
  inherit (lib.attrsets)
    attrsToList
    filterAttrs
    optionalAttrs
    mapAttrs'
    mapAttrsToList
    nameValuePair
    ;
  inherit (lib.generators) toKeyValue;
  inherit (lib) types;

  # Deeply checks types for a given type function. Calls `override` with type and value.
  deep =
    func: override: type:
    let
      prev = func type;
    in
    prev
    // {
      check =
        value:
        let
          prevResult = builtins.tryEval (prev.check value);
          nextResult = builtins.tryEval (override type value);
        in
        prevResult.success && prevResult.value && nextResult.success && nextResult.value;

      # We need to typecheck prior to merging, so deoptimize in case prev.merge is a functor.
      merge = opts: prev.merge opts;
    };

  # Deep listOf.
  inherit (types) listOf;
  listOf' = deep listOf (type: value: all type.check value);

  # Deep attrsOf.
  inherit (types) attrsOf;
  attrsOf' = deep attrsOf (type: value: all (item: type.check item.value) (attrsToList value));

  # Deep either and oneOf that performs typecheck prior to merging.
  inherit (types) either;
  either' =
    first: second:
    let
      prev = either first second;
    in
    prev
    // {
      check =
        value:
        let
          firstResult = builtins.tryEval (first.check value);
          secondResult = builtins.tryEval (second.check value);
        in
        firstResult.success && firstResult.value || secondResult.success && secondResult.value;

      # We need to typecheck prior to merging, so deoptimize in case prev.merge is a functor.
      merge = opts: prev.merge opts;
    };

  oneOf' =
    ts:
    let
      head' =
        if ts == [ ] then throw "types.oneOf needs to get at least one type in its argument" else head ts;
      tail' = tail ts;
    in
    foldl' either' head' tail';

  # Kismet config atoms.
  atom =
    with types;
    oneOf' [
      number
      bool
      str
    ];

  # Composite types.
  listOfAtom = listOf' atom;
  atomOrList = oneOf' [
    atom
    listOfAtom
  ];
  lists = listOf' atomOrList;
  kvPair = attrsOf' atomOrList;
  kvPairs = listOf' kvPair;

  # Options that eval to a string with a header (foo:key=value)
  headerKvPair = attrsOf' (attrsOf' atomOrList);
  headerKvPairs = attrsOf' (listOf' (attrsOf' atomOrList));

  # Toplevel config type.
  topLevel =
    let
      topLevel' = oneOf' [
        headerKvPairs
        headerKvPair
        kvPairs
        kvPair
        listOfAtom
        lists
        atom
      ];
    in
    attrsOf' topLevel'
    // {
      description = "Kismet config stanza";
    };

  # Throws invalid.
  invalid = atom: throw "invalid value '${toString atom}' of type '${typeOf atom}'";

  # Converts an atom.
  mkAtom =
    atom:
    if isString atom then
      if hasInfix "\"" atom || hasInfix "," atom then
        ''"${replaceStrings [ ''"'' ] [ ''\"'' ] atom}"''
      else
        atom
    else if isFloat atom || isInt atom || isBool atom then
      toString atom
    else
      invalid atom;

  # Converts an inline atom or list to a string.
  mkAtomOrListInline =
    atomOrList:
    if isList atomOrList then
      mkAtom "${concatMapStringsSep "," mkAtom atomOrList}"
    else
      mkAtom atomOrList;

  # Converts an out of line atom or list to a string.
  mkAtomOrList =
    atomOrList:
    if isList atomOrList then
      "${concatMapStringsSep "," mkAtomOrListInline atomOrList}"
    else
      mkAtom atomOrList;

  # Throws if the string matches the given regex.
  deny =
    regex: str:
    assert (match regex str) == null;
    str;

  # Converts a set of k/v pairs.
  convertKv = concatMapAttrsStringSep "," (
    name: value: "${mkAtom (deny "=" name)}=${mkAtomOrListInline value}"
  );

  # Converts k/v pairs with a header.
  convertKvWithHeader = header: attrs: "${mkAtom (deny ":" header)}:${convertKv attrs}";

  # Converts the entire config.
  convertConfig = mapAttrs' (
    name: value:
    let
      # Convert foo' into 'foo+' for support for '+=' syntax.
      newName = if hasSuffix "'" name then substring 0 (stringLength name - 1) name + "+" else name;

      # Get the stringified value.
      newValue =
        if headerKvPairs.check value then
          flatten (
            mapAttrsToList (header: values: (map (value: convertKvWithHeader header value) values)) value
          )
        else if headerKvPair.check value then
          mapAttrsToList convertKvWithHeader value
        else if kvPairs.check value then
          map convertKv value
        else if kvPair.check value then
          convertKv value
        else if listOfAtom.check value then
          mkAtomOrList value
        else if lists.check value then
          map mkAtomOrList value
        else if atom.check value then
          mkAtom value
        else
          invalid value;
    in
    nameValuePair newName newValue
  );

  mkKismetConf =
    options:
    (toKeyValue { listsAsDuplicateKeys = true; }) (
      filterAttrs (_: value: value != null) (convertConfig options)
    );

  cfg = config.services.kismet;
in
{
  options.services.kismet = {
    enable = mkEnableOption "kismet";
    package = mkPackageOption pkgs "kismet" { };

    dataDir = mkOption {
      default = "/var/lib/kismet";
      description = "The Kismet data directory.";
      type = types.path;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Literal Kismet config lines appended to the site config.
        Note that `services.kismet.settings` allows you to define
        all options here using Nix attribute sets.
      '';

      example = ''
        # Looks like the following in `services.kismet.settings`:
        # wepkey = [ "00:DE:AD:C0:DE:00" "FEEDFACE42" ];
        wepkey=00:DE:AD:C0:DE:00,FEEDFACE42
      '';

      type = types.str;
    };

    group = mkOption {
      default = "kismet";
      description = "The group to run Kismet as.";
      type = types.str;
    };

    httpd = {
      enable = mkOption {
        default = false;
        description = "True to enable the HTTP server.";
        type = types.bool;
      };

      address = mkOption {
        default = "127.0.0.1";
        description = "The address to listen on. Note that this cannot be a hostname or Kismet will not start.";
        type = types.str;
      };

      port = mkOption {
        default = 2501;
        description = "The port to listen on.";
        type = types.port;
      };
    };

    logTypes = mkOption {
      default = [ "kismet" ];
      description = "The log types.";
      type = with types; listOf str;
    };

    serverDescription = mkOption {
      default = "NixOS Kismet server";
      description = "The description of the server.";
      type = types.str;
    };

    serverName = mkOption {
      default = "Kismet";
      description = "The name of the server.";
      type = types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Options for Kismet. See:
        https://www.kismetwireless.net/docs/readme/configuring/configfiles/
      '';

      example = literalExpression ''
        {
          /* Examples for atoms */
          # dot11_link_bssts=false
          dot11_link_bssts = false; # Boolean

          # dot11_related_bss_window=10000000
          dot11_related_bss_window = 10000000; # Integer

          # devicefound=00:11:22:33:44:55
          devicefound = "00:11:22:33:44:55"; # String

          # log_types+=wiglecsv
          log_types' = "wiglecsv";

          /* Examples for lists of atoms */
          # wepkey=00:DE:AD:C0:DE:00,FEEDFACE42
          wepkey = [ "00:DE:AD:C0:DE:00" "FEEDFACE42" ];

          # alert=ADHOCCONFLICT,5/min,1/sec
          # alert=ADVCRYPTCHANGE,5/min,1/sec
          alert = [
            [ "ADHOCCONFLICT"  "5/min" "1/sec" ]
            [ "ADVCRYPTCHANGE" "5/min" "1/sec" ]
          ];

          /* Examples for sets of atoms */
          # source=wlan0:name=ath11k
          source.wlan0 = { name = "ath11k"; };

          /* Examples with colon-suffixed headers */
          # gps=gpsd:host=localhost,port=2947
          gps.gpsd = {
            host = "localhost";
            port = 2947;
          };

          # apspoof=Foo1:ssid=Bar1,validmacs="00:11:22:33:44:55,aa:bb:cc:dd:ee:ff"
          # apspoof=Foo1:ssid=Bar2,validmacs="01:12:23:34:45:56,ab:bc:cd:de:ef:f0"
          # apspoof=Foo2:ssid=Baz1,validmacs="11:22:33:44:55:66,bb:cc:dd:ee:ff:00"
          apspoof.Foo1 = [
            { ssid = "Bar1"; validmacs = [ "00:11:22:33:44:55" "aa:bb:cc:dd:ee:ff" ]; }
            { ssid = "Bar2"; validmacs = [ "01:12:23:34:45:56" "ab:bc:cd:de:ef:f0" ]; }
          ];

          # because Foo1 is a list, Foo2 needs to be as well
          apspoof.Foo2 = [
            {
              ssid = "Bar2";
              validmacs = [ "00:11:22:33:44:55" "aa:bb:cc:dd:ee:ff" ];
            };
          ];
        }
      '';

      type = topLevel;
    };

    user = mkOption {
      default = "kismet";
      description = "The user to run Kismet as.";
      type = types.str;
    };
  };

  config =
    let
      configDir = "${cfg.dataDir}/.kismet";
      settings =
        cfg.settings
        // {
          log_types = cfg.logTypes;
          logging_enabled = cfg.logTypes != [ ];
          server_description = cfg.serverDescription;
          server_name = cfg.serverName;
        }
        // optionalAttrs cfg.httpd.enable {
          httpd_auth_file = "${configDir}/kismet_httpd.conf";
          httpd_bind_address = cfg.httpd.address;
          httpd_home = "${cfg.package}/share/kismet/httpd";
          httpd_port = cfg.httpd.port;
        };
    in
    mkIf cfg.enable {
      systemd.services.kismet =
        let
          kismetConf = pkgs.writeText "kismet.conf" ''
            ${mkKismetConf settings}
            ${cfg.extraConfig}
          '';
        in
        {
          after = [
            "basic.target"
            "network.target"
          ];

          description = "Kismet monitoring service";

          serviceConfig =
            let
              capabilities = [
                "CAP_NET_ADMIN"
                "CAP_NET_RAW"
              ];
              kismetPreStart = pkgs.writeShellScript "kismet-pre-start" ''
                owner=${escapeShellArg "${cfg.user}:${cfg.group}"}
                mkdir -p ~/.kismet

                # Ensure permissions on directories Kismet uses.
                chown "$owner" ~/ ~/.kismet
                cd ~/.kismet

                package=${cfg.package}
                if [ -d "$package/etc" ]; then
                  for file in "$package/etc"/*.conf; do
                    # Symlink the config files if they exist or are already a link.
                    base="''${file##*/}"
                    if [ ! -f "$base" ] || [ -L "$base" ]; then
                      ln -sf "$file" "$base"
                    fi
                  done
                fi

                for file in kismet_httpd.conf; do
                  # Un-symlink these files.
                  if [ -L "$file" ]; then
                    cp "$file" ".$file"
                    rm -f "$file"
                    mv ".$file" "$file"
                    chmod 0640 "$file"
                    chown "$owner" "$file"
                  fi
                done

                # Link the site config.
                ln -sf ${kismetConf} kismet_site.conf
              '';
            in
            {
              AmbientCapabilities = capabilities;
              CapabilityBoundingSet = capabilities;

              ExecStart = escapeShellArgs [
                "${cfg.package}/bin/kismet"
                "--homedir"
                cfg.dataDir
                "--confdir"
                configDir
                "--datadir"
                "${cfg.package}/share"
                "--no-ncurses"
                "-f"
                "${configDir}/kismet.conf"
              ];

              ExecStartPre = "+${kismetPreStart}";
              Group = cfg.group;
              KillMode = "control-group";
              LockPersonality = true;
              NoNewPrivileges = true;
              PrivateDevices = false;
              PrivateTmp = true;
              PrivateUsers = false;
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHome = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = "invisible";
              ProtectSystem = "full";
              Restart = "always";
              RestrictNamespaces = true;
              RestrictSUIDSGID = true;
              TimeoutStopSec = 30;
              Type = "simple";
              UMask = "0007";
              User = cfg.user;
              WorkingDirectory = cfg.dataDir;
            };

          # Allow it to restart if the wifi interface is not up
          unitConfig.StartLimitIntervalSec = 5;
          wantedBy = [ "multi-user.target" ];
          wants = [ "basic.target" ];
        };

      systemd.tmpfiles.settings = {
        "10-kismet" = {
          ${cfg.dataDir} = {
            d = {
              inherit (cfg) user group;
              mode = "0750";
            };
          };

          ${configDir} = {
            d = {
              inherit (cfg) user group;
              mode = "0750";
            };
          };
        };
      };

      users.groups.${cfg.group} = { };

      users.users.${cfg.user} = {
        inherit (cfg) group;
        description = "User for running Kismet";
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

  meta.maintainers = with lib.maintainers; [ numinit ];
}
