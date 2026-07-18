{
  lib,
  bsdSetupHook,
  freebsdSetupHook,
  groff,
  install,
  localedef,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  symlinkJoin,
  tsort,
  allLocales ? true,
  locales ? [ "en_US.UTF-8" ],
}:
let
  build =
    name: needsLocaledef:
    mkDerivation {
      nativeBuildInputs = [
        bsdSetupHook
        freebsdSetupHook
        makeMinimal
        install
        tsort
        lorder
        mandoc
        groff
      ]
      ++ lib.optional needsLocaledef localedef;

      extraPaths = lib.optional needsLocaledef "tools/tools/locale/etc/final-maps";
      path = "share/${name}";
    };
  directories = {
    colldef = true;
    colldef_unicode = true;
    ctypedef = true;
    monetdef = false;
    monetdef_unicode = false;
    msgdef = false;
    msgdef_unicode = false;
    numericdef = false;
    numericdef_unicode = false;
    timedef = false;
  };
in
symlinkJoin {
  name = "freebsd-locales";
  paths = lib.mapAttrsToList build directories;
}
