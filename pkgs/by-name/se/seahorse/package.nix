{
  lib,
  stdenv,
  fetchurl,
  avahi,
  desktop-file-utils,
  fetchpatch,
  gcr,
  glib,
  glib-networking,
  gnome,
  gnupg,
  gpgme,
  gsettings-desktop-schemas,
  gtk3,
  itstool,
  libhandy,
  libpwquality,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  openldap,
  openssh,
  p11-kit,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seahorse";
  version = "47.0.1";

  src = fetchurl {
    url = "mirror://gnome/sources/seahorse/${lib.versions.major finalAttrs.version}/seahorse-${finalAttrs.version}.tar.xz";
    hash = "sha256-nBkX5KYff+u3h4Sc42znF/znBsNGiAuZHQVtVNrbysw=";
  };

  patches = [
    # Fix build with gpgme 2.0+
    # https://gitlab.gnome.org/GNOME/seahorse/-/merge_requests/248
    (fetchpatch {
      hash = "sha256-xd5K8xUGuMk+41JROsq7QpZ5gD2jPAbv1kQdLI3z9lc=";
      name = "seahorse-allow-build-with-gpgme-2_0.patch";
      url = "https://gitlab.gnome.org/GNOME/seahorse/-/commit/aa68522cc696fa491ccfdff735b77bcf113168d0.patch";
    })
  ];

  postPatch = ''
    patchShebangs build-aux/gpg_check_version.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    itstool
    wrapGAppsHook3
    python3
    openssh
    gnupg
    desktop-file-utils
    gcr
  ];

  buildInputs = [
    gtk3
    glib
    glib-networking
    gcr
    gsettings-desktop-schemas
    gpgme
    libsecret
    avahi
    libsoup_3
    p11-kit
    openldap
    libpwquality
    libhandy
  ];

  env =
    lib.optionalAttrs (stdenv.cc.isGNU && (lib.versionAtLeast (lib.getVersion stdenv.cc.cc) "14"))
      {
        NIX_CFLAGS_COMPILE = toString [
          "-Wno-error=implicit-function-declaration"
          "-Wno-error=int-conversion"
          "-Wno-error=return-mismatch"
        ];
      };

  doCheck = true;

  preCheck = ''
    # Add “org.gnome.crypto.pgp” GSettings schema to path
    # to make it available for “gpgme-backend” test.
    # It is used by Seahorse’s internal “common” library.
    addToSearchPath XDG_DATA_DIRS "${glib.getSchemaDataDirPath gcr}"
    # The same test also requires home directory so that it can store settings.
    export HOME=$TMPDIR
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # Pick up icons from Gcr
      --prefix XDG_DATA_DIRS : "${gcr}/share"
    )
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "seahorse";
    };
  };

  meta = {
    description = "Application for managing encryption keys and passwords in the GnomeKeyring";
    homepage = "https://gitlab.gnome.org/GNOME/seahorse";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "seahorse";
    teams = [ lib.teams.gnome ];
  };
})
