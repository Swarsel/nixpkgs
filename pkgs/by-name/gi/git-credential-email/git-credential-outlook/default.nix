{
  lib,
  callPackage,
}:

callPackage ../package.nix {
  pname = "git-credential-outlook";
  description = "Git credential helper for Microsoft Outlook accounts";
  license = lib.licenses.asl20;
  scripts = [ "git-credential-outlook" ];
}
