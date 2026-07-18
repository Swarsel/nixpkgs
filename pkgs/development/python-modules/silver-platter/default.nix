{
  lib,
  stdenv,
  breezy,
  buildPythonPackage,
  cargo,
  dulwich,
  jinja2,
  libiconv,
  openssl,
  pkg-config,
  pkgs,
  pyyaml,
  ruamel-yaml,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
}:

let
  inherit (pkgs) silver-platter;
in
buildPythonPackage {
  inherit (silver-platter)
    pname
    version
    src
    cargoDeps
    ;

  nativeBuildInputs = [
    setuptools-rust
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  dependencies = [
    setuptools
    breezy
    dulwich
    jinja2
    pyyaml
    ruamel-yaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "silver_platter" ];

  meta = {
    inherit (silver-platter.meta)
      description
      homepage
      license
      maintainers
      ;
  };
}
