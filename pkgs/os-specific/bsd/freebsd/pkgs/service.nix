{
  lib,
  env,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    substituteInPlace usr.sbin/service/service.sh --replace-fail /usr/bin/env ${lib.getExe env}
  '';

  path = "usr.sbin/service";
}
