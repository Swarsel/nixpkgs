{
  lib,
  buildEnv,
  callPackage,
  makeBinaryWrapper,
  postgresql,
}:
f:
let
  installedExtensions = f postgresql.pkgs;
  recurse = import ./wrapper.nix {
    # explicitly listed in case they were overridden
    inherit
      buildEnv
      callPackage
      lib
      makeBinaryWrapper
      postgresql
      ;
  };
in
buildEnv (finalAttrs: {
  inherit (postgresql) version;
  pname = "${postgresql.pname}-and-plugins";

  postBuild =
    let
      args = lib.concatMap (ext: ext.wrapperArgs or [ ]) installedExtensions;
    in
    ''
      wrapProgram "$out/bin/postgres" ${lib.concatStringsSep " " args}
    '';

  derivationArgs = {
    strictDeps = true;
    nativeBuildInputs = [ makeBinaryWrapper ];
  };

  paths = installedExtensions ++ [
    # consider keeping in-sync with `postBuild` below
    postgresql
    postgresql.man # in case user installs this into environment
  ];

  pathsToLink = [
    "/"
    "/bin"
    "/share/postgresql/extension"
    # Unbreaks Omnigres' build system
    "/share/postgresql/timezonesets"
    "/share/postgresql/tsearch_data"
  ];

  passthru = {
    inherit installedExtensions;

    inherit (postgresql)
      pkgs
      psqlSchema
      ;

    pg_config = postgresql.pg_config.override {
      outputs = {
        man = finalAttrs.finalPackage;
        out = finalAttrs.finalPackage;
      };
    };

    tests = lib.mapAttrs (
      _: test:
      if test.passthru or { } ? "override" then test.passthru.override finalAttrs.finalPackage else test
    ) postgresql.tests;

    withJIT = recurse (_: installedExtensions ++ [ postgresql.jit ]);
    withPackages = f': recurse (ps: installedExtensions ++ f' ps);
    withoutJIT = recurse (_: lib.remove postgresql.jit installedExtensions);
  };
})
