{
  lib,
  stdenv,
  fetchFromGitLab,
  alcotest,
  bisect_ppx,
  buildDunePackage,
  dune-configurator,
  gmp,
  integers,
  pkg-config,
  stdlib-random,
  zarith,
}:

buildDunePackage (
  rec {
    pname = "class_group_vdf";
    version = "0.0.5";

    src = fetchFromGitLab {
      owner = "nomadic-labs/cryptography";
      repo = "ocaml-chia-vdf";
      rev = "v${version}";
      hash = "sha256-/wPlS9JrQH+4kvEzsn2DCkAFhu0LMxlIIKQZ9jOJkco=";
    };

    nativeBuildInputs = [
      gmp
      pkg-config
      dune-configurator
    ];

    buildInputs = [
      dune-configurator
    ];

    propagatedBuildInputs = [
      zarith
      integers
      stdlib-random
    ];

    doCheck = true;

    checkInputs = [
      alcotest
      bisect_ppx
    ];

    minimalOCamlVersion = "4.08";

    meta = {
      description = "Verifiable Delay Functions bindings to Chia's VDF";
      homepage = "https://gitlab.com/nomadic-labs/tezos";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.ulrikstrid ];
    };
  }
  # Darwin sdk on intel target 10.12 (2016) at the time of writing. It is likely that host will be at least 10.14 (2018). This fix allow it to build and run on 10.14 and build on 10.12 (but don't run).
  //
    lib.optionalAttrs
      (
        lib.versionOlder stdenv.hostPlatform.darwinMinVersion "10.14"
        && stdenv.hostPlatform.isMacOS
        && stdenv.hostPlatform.isx86_64
      )
      {
        preHook = ''
          export MACOSX_DEPLOYMENT_TARGET=10.14
        '';
      }
)
