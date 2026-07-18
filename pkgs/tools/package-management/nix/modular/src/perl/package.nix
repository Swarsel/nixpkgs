{
  lib,
  stdenv,
  bzip2,
  curl,
  libsodium,
  mkMesonDerivation,
  nix-store,
  perl,
  perlPackages,
  pkg-config,
  version,
}:

perl.pkgs.toPerlModule (
  mkMesonDerivation (finalAttrs: {
    inherit version;
    pname = "nix-perl";
    strictDeps = false;

    nativeBuildInputs = [
      pkg-config
      perl
      curl
    ];

    buildInputs = [
      nix-store
      bzip2
      libsodium
    ];

    mesonFlags = [
      (lib.mesonOption "dbi_path" "${perlPackages.DBI}/${perl.libPrefix}")
      (lib.mesonOption "dbd_sqlite_path" "${perlPackages.DBDSQLite}/${perl.libPrefix}")
      (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
    ];

    preConfigure =
      # "Inline" .version so its not a symlink, and includes the suffix
      ''
        chmod u+w .version
        echo ${finalAttrs.version} > .version
      '';

    # `perlPackages.Test2Harness` is marked broken for Darwin
    doCheck = !stdenv.hostPlatform.isDarwin;

    nativeCheckInputs = [
      perlPackages.Test2Harness
    ];

    mesonCheckFlags = [
      "--print-errorlogs"
    ];

    workDir = ./.;
  })
)
