{
  stdenv,
  cargo,
  meson,
  ninja,
  oo7,
  pkg-config,
  rustPlatform,
  rustc,
  systemdLibs,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (oo7) version src cargoDeps;
  pname = "oo7-pam";
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  buildInputs = [
    systemdLibs
  ];

  __structuredAttrs = true;
  cargoRoot = "../";
  separateDebugInfo = true;
  sourceRoot = "${finalAttrs.src.name}/pam";

  meta = {
    inherit (oo7.meta)
      homepage
      changelog
      license
      maintainers
      platforms
      ;

    description = "${oo7.meta.description} (PAM modules)";
  };
})
