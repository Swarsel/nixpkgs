{
  lib,
  stdenv,
  fetchFromGitHub,
  openldap,
  pam,
  perl,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pam_ldap";
  version = "0-unstable-2024-02-22";

  src = fetchFromGitHub {
    owner = "PADL";
    repo = "pam_ldap";
    rev = "656448f091cbeb9efb3ece08e6868e40b8e7b6f8";
    hash = "sha256-o2RBewxhaXcMW9KIRwlxFv6YaWxaBngafvjEYxFchX4=";
  };

  postPatch = ''
    patchShebangs ./vers_string
    substituteInPlace vers_string --replace "cvslib.pl" "./cvslib.pl"
  '';

  nativeBuildInputs = [ perl ];

  buildInputs = [
    pam
    openldap
  ];

  preInstall = "
    substituteInPlace Makefile --replace '-o root -g root' ''
  ";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    inherit (pam.meta) platforms;
    description = "LDAP backend for PAM";

    longDescription = ''
      The pam_ldap module provides the means for Solaris and Linux servers and
      workstations to authenticate against LDAP directories, and to change their
      passwords in the directory.'';

    homepage = "https://www.padl.com/OSS/pam_ldap.html";
    changelog = "https://github.com/PADL/pam_ldap/blob/master/ChangeLog";
    license = lib.licenses.gpl2;
  };
})
