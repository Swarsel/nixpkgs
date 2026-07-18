{
  config,
  lib,
  options,
  ...
}:
{

  ###### interface

  options = {

    services.mail = {

      sendmailSetuidWrapper = lib.mkOption {
        default = null;

        description = ''
          Configuration for the sendmail setuid wapper.
        '';

        internal = true;
        type = lib.types.nullOr options.security.wrappers.type.nestedTypes.elemType;
      };

    };

  };

  ###### implementation

  config = lib.mkIf (config.services.mail.sendmailSetuidWrapper != null) {

    security.wrappers.sendmail = config.services.mail.sendmailSetuidWrapper;

  };

}
