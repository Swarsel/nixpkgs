{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fediwall;
  pkg = cfg.package.override { conf = cfg.settings; };
  format = pkgs.formats.json { };
in
{
  options.services.fediwall = {
    enable = lib.mkEnableOption "fediwall, a social media wall for the fediverse";
    package = lib.mkPackageOption pkgs "fediwall" { };

    hostName = lib.mkOption {
      default = config.networking.fqdnOrHostName;
      defaultText = lib.literalExpression "config.networking.fqdnOrHostName";
      description = "The hostname to serve fediwall on.";
      example = "fediwall.example.org";
      type = lib.types.str;
    };

    nginx = lib.mkOption {
      default = { };
      description = "Allows customizing the nginx virtualHost settings";

      example = lib.literalExpression ''
        {
          serverAliases = [
            "fedi.''${config.networking.domain}"
          ];
          # Enable TLS and use let's encrypt for ACME
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = lib.types.submodule (
        lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) { }
      );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Fediwall configuration. See
        https://github.com/defnull/fediwall/blob/main/public/wall-config.json.example
        for information on supported values.
      '';

      type = lib.types.submodule {
        options = {
          hideBoosts = lib.mkOption {
            default = false;
            description = "Hide boosts";
            type = lib.types.bool;
          };

          hideBots = lib.mkOption {
            default = true;
            description = "Hide posts from bot accounts";
            type = lib.types.bool;
          };

          hideReplies = lib.mkOption {
            default = true;
            description = "Hide replies";
            type = lib.types.bool;
          };

          hideSensitive = lib.mkOption {
            default = true;
            description = "Hide sensitive (potentially NSFW) posts";
            type = lib.types.bool;
          };

          loadFederated = lib.mkOption {
            default = false;
            description = "Load federated posts";
            type = lib.types.bool;
          };

          loadPublic = lib.mkOption {
            default = false;
            description = "Load public posts";
            type = lib.types.bool;
          };

          loadTrends = lib.mkOption {
            default = false;
            description = "Load trending posts";
            type = lib.types.bool;
          };

          playVideos = lib.mkOption {
            default = true;
            description = "Autoplay videos in posts";
            type = lib.types.bool;
          };

          servers = lib.mkOption {
            default = [ "mastodon.social" ];
            description = "Servers to load posts from";
            type = with lib.types; listOf str;
          };

          showMedia = lib.mkOption {
            default = true;
            description = "Show media in posts";
            type = lib.types.bool;
          };

          tags = lib.mkOption {
            default = [ ];
            description = "Tags to follow";
            example = lib.literalExpression "[ \"cats\" \"dogs\"]";
            type = with lib.types; listOf str;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = lib.mkDefault true;

      virtualHosts."${cfg.hostName}" = lib.mkMerge [
        cfg.nginx
        {
          locations = {
            "/" = {
              index = "index.html";
            };
          };

          root = lib.mkForce "${pkg}";
        }
      ];
    };
  };
}
