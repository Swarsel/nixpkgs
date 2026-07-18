{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  # dependencies
  range-typed-integers,
  rustPlatform,
  rustc,
  # build-system
  setuptools-rust,
}:

buildPythonPackage (finalAttrs: {
  pname = "skytemple-rust";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-rust";
    tag = finalAttrs.version;
    hash = "sha256-yJ78P00h4SITVuDnIh5IIlWkoed/VtIw3NB8ETB95bk=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  env = {
    GETTEXT_SYSTEM = true;
    # Python 3.14 compatibility
    # error: the configured Python interpreter version (3.14) is newer than PyO3's maximum supported
    # version (3.13)
    PYO3_USE_ABI3_FORWARD_COMPATIBILITY = 1;
  };

  doCheck = false; # tests for this package are in skytemple-files package

  build-system = [
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-9OgUuuMuo2l4YsZMhBZJBqKqbNwj1W4yidoogjcNgm8=";
  };

  dependencies = [
    range-typed-integers
  ];

  pyproject = true;
  pythonImportsCheck = [ "skytemple_rust" ];

  meta = {
    description = "Binary Rust extensions for SkyTemple";
    homepage = "https://github.com/SkyTemple/skytemple-rust";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
})
