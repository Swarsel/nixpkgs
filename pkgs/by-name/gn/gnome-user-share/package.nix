{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  apacheHttpdPackages,
  buildPackages,
  cargo,
  common-updater-scripts,
  gettext,
  glib,
  gnome,
  itstool,
  libxml2,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsNoGuiHook,
}:

let
  inherit (apacheHttpdPackages) apacheHttpd mod_dnssd;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-user-share";
  version = "48.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-user-share/${lib.versions.major finalAttrs.version}/gnome-user-share-${finalAttrs.version}.tar.xz";
    hash = "sha256-oE1IP0mz92naj/Xi0/y/++rztsa3HYLSoqYju0seDdQ=";
  };

  postPatch = ''
    substituteInPlace src/meson.build \
      --replace-fail "'cp', 'src' / rust_target / meson.project_name(), '@OUTPUT@'," "'cp', 'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name(), '@OUTPUT@',"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    rustc
    rustPlatform.cargoSetupHook
    cargo
    gettext
    glib # for glib-compile-schemas
    itstool
    libxml2
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dhttpd=${apacheHttpd.out}/bin/httpd"
    "-Dmodules_path=${apacheHttpd}/modules"
    "-Dsystemduserunitdir=${placeholder "out"}/etc/systemd/user"
  ];

  # For https://gitlab.gnome.org/GNOME/gnome-user-share/-/blob/7ffb23dd5af0fda75c66f03756798dc10e253c36/src/meson.build#L47
  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  preConfigure = ''
    substituteInPlace data/dav_user_2.4.conf \
      --replace-fail \
        'LoadModule dnssd_module ''${HTTP_MODULES_PATH}/mod_dnssd.so' \
        'LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so' \
      --replace-fail \
        '${"$"}{HTTP_MODULES_PATH}' \
        '${apacheHttpd}/modules'
  ''
  + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace meson.build --replace-fail \
      "run_command([httpd, '-v']" \
      "run_command(['${stdenv.hostPlatform.emulator buildPackages}', httpd, '-v']"
  '';

  doCheck = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-tQoP0yBOCesj2kwgBUoqmcVtFttwML2N+wfSULtfC4w=";
    name = "gnome-user-share-${finalAttrs.version}";
  };

  passthru = {
    updateScript =
      let
        updateSource = gnome.updateScript {
          packageName = "gnome-user-share";
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
              update-source-version gnome-user-share --ignore-same-version --source-key=cargoDeps.vendorStaging > /dev/null
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
    description = "Service that exports the contents of the Public folder in your home directory on the local network";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-user-share";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-user-share/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
