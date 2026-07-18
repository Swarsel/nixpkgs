{
  lib,
  callPackage,
}:

callPackage ../package.nix {
  pname = "git-protonmail";
  description = "Git helper to use ProtonMail API to send emails";
  license = lib.licenses.gpl3Only;
  scripts = [ "git-protonmail" ];
}
