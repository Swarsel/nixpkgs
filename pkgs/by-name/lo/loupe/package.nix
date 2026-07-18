{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  cargo,
  common-updater-scripts,
  desktop-file-utils,
  glycin-loaders,
  gnome,
  gtk4,
  itstool,
  lcms2,
  libadwaita,
  libglycin,
  libgweather,
  libseccomp,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "loupe";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/loupe/${lib.versions.major finalAttrs.version}/loupe-${finalAttrs.version}.tar.xz";
    hash = "sha256-euT7rl4ZMWqmQMVvgNxaeRRIpi3Y8P8G4ppYutgTqZQ=";
  };

  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "'src' / rust_target / meson.project_name()," \
      "'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name(),"
  '';

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    itstool
    libglycin.patchVendorHook
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    libglycin.setupHook
    glycin-loaders
    gtk4
    lcms2
    libadwaita
    libgweather
    libseccomp
  ];

  # For https://gitlab.gnome.org/GNOME/loupe/-/blob/0e6ddb0227ac4f1c55907f8b43eaef4bb1d3ce70/src/meson.build#L34-35
  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-I4z5qjX10AUuwk+JdX/1ZU0uCAVPQj8HkEc+n9aMczE=";
    name = "loupe-deps-${finalAttrs.version}";
  };

  passthru = {
    updateScript =
      let
        updateSource = gnome.updateScript {
          packageName = "loupe";
        };

        updateLockfile = {
          command = [
            "sh"
            "-c"
            ''
              PATH=${
                lib.makeBinPath [
                  common-updater-scripts
                ]
              }
              update-source-version loupe --ignore-same-version --source-key=cargoDeps.vendorStaging > /dev/null
            ''
          ];

          # Experimental feature: do not copy!
          supportedFeatures = [ "silent" ];
        };
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateLockfile
      ];
  };

  meta = {
    description = "Simple image viewer application written with GTK4 and Rust";
    homepage = "https://gitlab.gnome.org/GNOME/loupe";
    changelog = "https://gitlab.gnome.org/GNOME/loupe/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jk ];
    platforms = lib.platforms.unix;
    mainProgram = "loupe";
    teams = [ lib.teams.gnome ];
  };
})
