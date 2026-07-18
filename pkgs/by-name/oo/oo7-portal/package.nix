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
  pname = "oo7-portal";

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

  cargoRoot = "../";
  sourceRoot = "${finalAttrs.src.name}/portal";

  meta = {
    inherit (oo7.meta)
      homepage
      changelog
      license
      maintainers
      platforms
      ;

    description = "${oo7.meta.description} (XDG Desktop Portal)";
  };
})
