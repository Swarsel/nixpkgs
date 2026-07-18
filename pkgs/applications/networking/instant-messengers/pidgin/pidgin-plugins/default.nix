{
  lib,
  config,
  newScope,
  pidgin,
  texliveBasic,
}:

lib.makeScope newScope (
  self:
  let
    callPackage = self.callPackage;
  in
  {
    pidgin = callPackage ../. {
      plugins = [ ];
      withGnutls = config.pidgin.gnutls or false;
      withOpenssl = config.pidgin.openssl or true;
    };

    pidgin-carbons = callPackage ./carbons { };
    pidgin-indicator = callPackage ./pidgin-indicator { };

    pidgin-latex = callPackage ./pidgin-latex {
      texLive = texliveBasic;
    };

    pidgin-osd = callPackage ./pidgin-osd { };
    pidgin-otr = callPackage ./otr { };
    pidgin-sipe = callPackage ./sipe { };
    pidgin-window-merge = callPackage ./window-merge { };
    pidgin-xmpp-receipts = callPackage ./pidgin-xmpp-receipts { };
    pidginPackages = self;
    purple-discord = callPackage ./purple-discord { };
    purple-googlechat = callPackage ./purple-googlechat { };
    purple-lurch = callPackage ./purple-lurch { };
    purple-mm-sms = callPackage ./purple-mm-sms { };
    purple-plugin-pack = callPackage ./purple-plugin-pack { };
    purple-slack = callPackage ./purple-slack { };
    purple-xmpp-http-upload = callPackage ./purple-xmpp-http-upload { };

  }
  // lib.optionalAttrs config.allowAliases {
    pidgin-mra = throw "'pidginPackages.pidgin-mra' has been removed since mail.ru agent service has stopped functioning in 2024.";
    pidgin-msn-pecan = throw "'pidginPackages.pidgin-msn-pecan' has been removed as it's unmaintained upstream and doesn't work with escargot";
    pidgin-opensteamworks = throw "'pidginPackages.pidgin-opensteamworks' has been removed as it is unmaintained and no longer works with Steam.";
    pidgin-skypeweb = throw "'pidginPackages.pidgin-skypeweb' has been removed since Skype was shut down in May 2025.";
    purple-facebook = throw "'pidginPackages.purple-facebook' has been removed as it is unmaintained and doesn't support e2ee enforced by facebook.";
    purple-hangouts = throw "'pidginPackages.purple-hangouts' has been removed as Hangouts Classic is obsolete and migrated to Google Chat.";
    purple-matrix = throw "'pidginPackages.purple-matrix' has been unmaintained since April 2022, so it was removed.";
    purple-vk-plugin = throw "'pidginPackages.purple-vk-plugin' has been removed as upstream repository was deleted and no active forks are found.";
    tdlib-purple = throw "'pidginPackages.tdlib-purple' has been removed due to being broken for more than a year; see RFC 180"; # Added 2026-02-05
  }
)
