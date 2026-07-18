{
  lib,
  expect,
  stdenvNoCC,
  subversion,
  openssh ? null,
  sshSupport ? true,
}:
{
  password,
  url,
  username,
  outputHash ? lib.fakeHash,
  outputHashAlgo ? null,
  rev ? "HEAD",
}:

lib.fetchers.withNormalizedHash { } (
  stdenvNoCC.mkDerivation {
    inherit outputHash outputHashAlgo;

    inherit
      username
      password
      url
      rev
      sshSupport
      openssh
      ;

    nativeBuildInputs = [
      subversion
      expect
    ];

    builder = ./builder.sh;
    name = "svn-export-ssh";
    outputHashMode = "recursive";
    sshSubversion = ./sshsubversion.exp;
  }
)
