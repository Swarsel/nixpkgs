{
  lib,
  callPackage,
}:

callPackage ../package.nix {
  pname = "git-msgraph";
  description = "Git helper to use Microsoft Graph API instead of SMTP to send emails";
  license = lib.licenses.asl20;
  scripts = [ "git-msgraph" ];
}
