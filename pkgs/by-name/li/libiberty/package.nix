{
  lib,
  stdenv,
  buildPackages,
  staticBuild ? stdenv.hostPlatform.isStatic,
}:

let
  inherit (buildPackages.buildPackages) gcc;
in

stdenv.mkDerivation {
  inherit (gcc.cc) src;
  pname = "libiberty";
  version = "${gcc.cc.version}";

  outputs = [
    "out"
    "dev"
  ];

  # needed until config scripts are updated to not use /usr/bin/uname on FreeBSD native
  # updateAutotoolsGnuConfigScriptsHook doesn't seem to work here
  postPatch = ''
    substituteInPlace ../config.guess --replace-fail /usr/bin/uname uname
  '';

  configureFlags = [ "--enable-install-libiberty" ] ++ lib.optional (!staticBuild) "--enable-shared";

  postInstall = lib.optionalString (!staticBuild) ''
    cp pic/libiberty.a $out/lib*/libiberty.a
  '';

  postUnpack = "sourceRoot=\${sourceRoot}/libiberty";

  meta = {
    description = "Collection of subroutines used by various GNU programs";
    homepage = "https://gcc.gnu.org/";
    license = lib.licenses.lgpl2;

    maintainers = with lib.maintainers; [
      ericson2314
    ];

    platforms = lib.platforms.unix;
  };
}
