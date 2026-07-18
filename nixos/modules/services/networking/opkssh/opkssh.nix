{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.opkssh;

  providerFile = pkgs.writeText "opkssh-providers" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: provider: "${provider.issuer} ${provider.clientId} ${provider.lifetime}"
      ) cfg.providers
    )
  );

  authIdFile = pkgs.writeText "opkssh-auth-id" (
    lib.concatStringsSep "\n" (
      lib.map (auth: "${auth.user} ${auth.principal} ${auth.issuer}") cfg.authorizations
    )
  );
in
{
  options.services.opkssh = {
    enable = lib.mkEnableOption "OpenID Connect SSH authentication";
    package = lib.mkPackageOption pkgs "opkssh" { };

    authorizations = lib.mkOption {
      default = [ ];
      description = "User authorization mappings";

      example = lib.literalExpression ''
        # This example refers to values in the providers example
        # adjust your expressions as necessary
        [
          {
            user = "alice";
            principal = "alice@gmail.com";
            inherit (config.services.opkssh.providers.google) issuer;
          }
          {
            user = "bob";
            principal = "repo:NixOs/nixpkgs:environment:production";
            inherit (config.services.opkssh.providers.github) issuer;
          }
        ];
      '';

      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            issuer = lib.mkOption {
              description = "Issuer URI";
              type = lib.types.str;
            };

            principal = lib.mkOption {
              description = "Principal identifier (email, repo, etc.)";
              type = lib.types.str;
            };

            user = lib.mkOption {
              description = "Linux user to authorize";
              type = lib.types.str;
            };
          };
        }
      );
    };

    group = lib.mkOption {
      default = "opksshuser";
      description = "System group for opkssh";
      type = lib.types.str;
    };

    providers = lib.mkOption {
      default = {
        github = {
          clientId = "github";
          issuer = "https://token.actions.githubusercontent.com";
          lifetime = "oidc";
        };

        google = {
          clientId = "206584157355-7cbe4s640tvm7naoludob4ut1emii7sf.apps.googleusercontent.com";
          issuer = "https://accounts.google.com";
          lifetime = "24h";
        };

        microsoft = {
          clientId = "096ce0a3-5e72-4da8-9c86-12924b294a01";
          issuer = "https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0";
          lifetime = "24h";
        };
      };

      description = "OpenID Connect providers configuration";

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            clientId = lib.mkOption {
              description = "OAuth client ID";
              type = lib.types.str;
            };

            issuer = lib.mkOption {
              description = "Issuer URI";
              example = "https://accounts.google.com";
              type = lib.types.str;
            };

            lifetime = lib.mkOption {
              default = "24h";
              description = "Token lifetime";

              type = lib.types.enum [
                "12h"
                "24h"
                "48h"
                "1week"
                "oidc"
                "oidc-refreshed"
              ];
            };
          };
        }
      );
    };

    user = lib.mkOption {
      default = "opksshuser";
      description = "System user for running opkssh";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."opk/auth_id" = {
      group = cfg.group;
      mode = "0640";
      source = authIdFile;
      user = cfg.user;
    };

    environment.etc."opk/providers" = {
      group = cfg.group;
      mode = "0640";
      source = providerFile;
      user = cfg.user;
    };

    security.wrappers."opkssh" = {
      group = "root";
      owner = "root";
      source = "${cfg.package}/bin/opkssh";
    };

    services.openssh = {
      authorizedKeysCommand = "/run/wrappers/bin/opkssh verify %u %k %t";
      authorizedKeysCommandUser = cfg.user;
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      description = "OpenPubkey OpenID Connect SSH User";
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ datosh ];
}
