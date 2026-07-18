{
  config,
  lib,
  name,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {

    alias = mkOption {
      default = null;

      description = ''
        Alias directory for requests. See <https://httpd.apache.org/docs/2.4/mod/mod_alias.html#alias>.
      '';

      example = "/your/alias/directory";
      type = with types; nullOr path;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        These lines go to the end of the location verbatim.
      '';

      type = types.lines;
    };

    index = mkOption {
      default = null;

      description = ''
        Adds DirectoryIndex directive. See <https://httpd.apache.org/docs/2.4/mod/mod_dir.html#directoryindex>.
      '';

      example = "index.php index.html";
      type = with types; nullOr str;
    };

    priority = mkOption {
      default = 1000;

      description = ''
        Order of this location block in relation to the others in the vhost.
        The semantics are the same as with `lib.mkOrder`. Smaller values have
        a greater priority.
      '';

      type = types.int;
    };

    proxyPass = mkOption {
      default = null;

      description = ''
        Sets up a simple reverse proxy as described by <https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html#simple>.
      '';

      example = "http://www.example.org/";
      type = with types; nullOr str;
    };

  };
}
