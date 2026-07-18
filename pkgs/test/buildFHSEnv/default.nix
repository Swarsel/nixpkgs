{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  callPackage,
  dpkg,
  glibc,
  runCommand,
}:

let
  getSharedObjectFromDebian =
    sharedObjectName: src:
    stdenv.mkDerivation {
      inherit src;

      nativeBuildInputs = [
        dpkg
      ];

      installPhase = ''
        echo shared objects found are:
        ls -l usr/lib/*/
        cp usr/lib/*/${sharedObjectName} $out
      '';

      dontBuild = true;
      dontConfigure = true;
      dontFixup = true;
      name = "${sharedObjectName}-fetcher";
    };

  makeSharedObjectTest =
    sharedObject: targetPkgs:
    let
      lddFHSEnv = buildFHSEnv {
        inherit targetPkgs;
        name = "ldd-with-ncurses-FHS-env";
        runScript = "ldd";
      };
      ldd-in-FHS = "${lddFHSEnv}/bin/${lddFHSEnv.name}";
      ldd = "${lib.getBin glibc}/bin/ldd";
      find_libFHSEnv = buildFHSEnv {
        name = "ls-with-ncurses-FHS-env";
        runScript = "find /lib/ -executable";

        targetPkgs = p: [
          p.ncurses5
        ];
      };
      find_lib-in-FHS = "${find_libFHSEnv}/bin/${find_libFHSEnv.name}";
    in
    runCommand "FHS-lib-test"
      {
        meta = {
          # Downloads an x86_64-linux only binary
          platforms = [ "x86_64-linux" ];
        };
      }
      ''
        echo original ldd output is:
        ${ldd} ${sharedObject}
        lddOutput="$(${ldd-in-FHS} ${sharedObject})"
        echo ldd output inside FHS is:
        echo "$lddOutput"
        if echo $lddOutput | grep -q "not found"; then
          echo "shared object could not find all dependencies in the FHS!"
          echo The libraries below where found in the FHS:
          ${find_lib-in-FHS}
          exit 1
        else
          echo $lddOutput > $out
        fi
      '';

in
{
  liblzma =
    makeSharedObjectTest
      (getSharedObjectFromDebian "libxml2.so.2.9.14" (fetchurl {
        hash = "sha256-NbdstwOPwclAIEpPBfM/+3nQJzU85Gk5fZrc+Pmz4ac=";
        url = "mirror://debian/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3~deb12u1_amd64.deb";
      }))
      (p: [
        p.xz
        p.zlib
        p.icu72
      ]);

  # This test proves an issue with buildFHSEnv - don't expect it to succeed,
  # this is discussed in https://github.com/NixOS/nixpkgs/pull/279844 .
  libtinfo =
    makeSharedObjectTest
      (getSharedObjectFromDebian "libedit.so.2.0.70" (fetchurl {
        hash = "sha256-HPFKvycW0yedsS0GV6VzfPcAdKHnHTvfcyBmJePInOY=";
        url = "mirror://debian/pool/main/libe/libedit/libedit2_3.1-20221030-2_amd64.deb";
      }))
      (p: [
        p.libtinfo
        p.libbsd
      ]);
}
