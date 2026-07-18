{ lib }:

with lib;
with lib.types;
{
  options = {

    extraConfig = mkOption {
      default = "";
      description = "Extra lines to be added verbatim to the vrrp_script section.";
      type = lines;
    };

    fall = mkOption {
      default = 3;
      description = "Required number of failures for KO transition.";
      type = int;
    };

    group = mkOption {
      default = null;
      description = "Name of group to run the script under. Defaults to user group.";
      type = nullOr str;
    };

    interval = mkOption {
      default = 1;
      description = "Seconds between script invocations.";
      type = int;
    };

    rise = mkOption {
      default = 5;
      description = "Required number of successes for OK transition.";
      type = int;
    };

    script = mkOption {
      description = "(Path of) Script command to execute followed by args, i.e. cmd [args]...";
      example = literalExpression ''"''${pkgs.curl} -f http://localhost:80"'';
      type = str;
    };

    timeout = mkOption {
      default = 5;
      description = "Seconds after which script is considered to have failed.";
      type = int;
    };

    user = mkOption {
      default = "keepalived_script";
      description = "Name of user to run the script under.";
      type = str;
    };

    weight = mkOption {
      default = 0;
      description = "Following a failure, adjust the priority by this weight.";
      type = int;
    };

  };

}
