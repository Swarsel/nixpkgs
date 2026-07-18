{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.webhook;
  defaultUser = "webhook";

  hookFormat = pkgs.formats.json { };

  hookType = types.submodule (
    { name, ... }:
    {
      options = {
        execute-command = mkOption {
          description = "The command that should be executed when the hook is triggered.";
          type = types.str;
        };

        id = mkOption {
          default = name;

          description = ''
            The ID of your hook. This value is used to create the HTTP endpoint (`protocol://yourserver:port/prefix/''${id}`).
          '';

          type = types.str;
        };
      };

      freeformType = hookFormat.type;
    }
  );

  hookFiles =
    mapAttrsToList (name: hook: hookFormat.generate "webhook-${name}.json" [ hook ]) cfg.hooks
    ++ mapAttrsToList (
      name: hook: pkgs.writeText "webhook-${name}.json.tmpl" "[${hook}]"
    ) cfg.hooksTemplated;

in
{
  options = {
    services.webhook = {
      enable = mkEnableOption ''
        [Webhook](https://github.com/adnanh/webhook), a server written in Go that allows you to create HTTP endpoints (hooks),
        which execute configured commands for any person or service that knows the URL
      '';

      package = mkPackageOption pkgs "webhook" { };

      enableTemplates = mkOption {
        default = cfg.hooksTemplated != { };
        defaultText = literalExpression "hooksTemplated != {}";

        description = ''
          Enable the generated hooks file to be parsed as a Go template.
          See [the documentation](https://github.com/adnanh/webhook/blob/master/docs/Templates.md) for more information.
        '';

        type = types.bool;
      };

      environment = mkOption {
        default = { };
        description = "Extra environment variables passed to webhook.";
        type = types.attrsOf types.str;
      };

      extraArgs = mkOption {
        default = [ ];

        description = ''
          These are arguments passed to the webhook command in the systemd service.
          You can find the available arguments and options in the [documentation][parameters].

          [parameters]: https://github.com/adnanh/webhook/blob/master/docs/Webhook-Parameters.md
        '';

        example = [ "-secure" ];
        type = types.listOf types.str;
      };

      group = mkOption {
        default = defaultUser;

        description = ''
          Webhook will be run under this group.

          If set, you must create this group yourself!
        '';

        type = types.str;
      };

      hooks = mkOption {
        default = { };

        description = ''
          The actual configuration of which hooks will be served.

          Read more on the [project homepage] and on the [hook definition] page.
          At least one hook needs to be configured.

          [hook definition]: https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md
          [project homepage]: https://github.com/adnanh/webhook#configuration
        '';

        example = {
          echo = {
            execute-command = "echo";
            response-message = "Webhook is reachable!";
          };

          redeploy-webhook = {
            command-working-directory = "/var/webhook";
            execute-command = "/var/scripts/redeploy.sh";
          };
        };

        type = types.attrsOf hookType;
      };

      hooksTemplated = mkOption {
        default = { };

        description = ''
          Same as {option}`hooks`, but these hooks are specified as literal strings instead of Nix values,
          and hence can include [template syntax](https://github.com/adnanh/webhook/blob/master/docs/Templates.md)
          which might not be representable as JSON.

          Template syntax requires the {option}`enableTemplates` option to be set to `true`, which is
          done by default if this option is set.
        '';

        example = {
          echo-template = ''
            {
              "id": "echo-template",
              "execute-command": "echo",
              "response-message": "{{ getenv "MESSAGE" }}"
            }
          '';
        };

        type = types.attrsOf types.str;
      };

      ip = mkOption {
        default = "0.0.0.0";

        description = ''
          The IP webhook should serve hooks on.

          The default means it can be reached on any interface if `openFirewall = true`.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open the configured port in the firewall for external ingress traffic.
          Preferably the Webhook server is instead put behind a reverse proxy.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 9000;
        description = "The port webhook should be reachable from.";
        type = types.port;
      };

      urlPrefix = mkOption {
        default = "hooks";

        description = ''
          The URL path prefix to use for served hooks (`protocol://yourserver:port/''${prefix}/hook-id`).
        '';

        type = types.str;
      };

      user = mkOption {
        default = defaultUser;

        description = ''
          Webhook will be run under this user.

          If set, you must create this user yourself!
        '';

        type = types.str;
      };

      verbose = mkOption {
        default = true;
        description = "Whether to show verbose output.";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      let
        overlappingHooks = builtins.intersectAttrs cfg.hooks cfg.hooksTemplated;
      in
      [
        {
          assertion = hookFiles != [ ];
          message = "At least one hook needs to be configured for webhook to run.";
        }
        {
          assertion = overlappingHooks == { };
          message = "`services.webhook.hooks` and `services.webhook.hooksTemplated` have overlapping attribute(s): ${concatStringsSep ", " (builtins.attrNames overlappingHooks)}";
        }
      ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.webhook = {
      after = [ "network.target" ];
      description = "Webhook service";
      environment = config.networking.proxy.envVars // cfg.environment;

      script =
        let
          args = [
            "-ip"
            cfg.ip
            "-port"
            (toString cfg.port)
            "-urlprefix"
            cfg.urlPrefix
          ]
          ++ concatMap (hook: [
            "-hooks"
            hook
          ]) hookFiles
          ++ optional cfg.enableTemplates "-template"
          ++ optional cfg.verbose "-verbose"
          ++ cfg.extraArgs;
        in
        ''
          ${cfg.package}/bin/webhook ${escapeShellArgs args}
        '';

      serviceConfig = {
        Group = cfg.group;
        Restart = "on-failure";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.user == defaultUser && cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        description = "Webhook daemon user";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
