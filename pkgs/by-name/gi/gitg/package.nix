{
  lib,
  stdenv,
  fetchurl,
  bash,
  fetchpatch,
  glib,
  gnome,
  gobject-introspection,
  gpgme,
  gsettings-desktop-schemas,
  gspell,
  gtk3,
  gtksourceview4,
  gvfs,
  json-glib,
  libdazzle,
  libgee,
  libgit2-glib,
  libhandy,
  libpeas,
  libsecret,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gitg";
  version = "44";

  src = fetchurl {
    url = "mirror://gnome/sources/gitg/${lib.versions.majorMinor finalAttrs.version}/gitg-${finalAttrs.version}.tar.xz";
    hash = "sha256-NCoxaE2rlnHNNBvT485mWtzuBGDCoIHdxJPNvAMTJTA=";
  };

  patches = [
    # Switch to girepository-2.0
    # https://gitlab.gnome.org/GNOME/gitg/-/merge_requests/278
    (fetchpatch {
      hash = "sha256-9pC7wrxWcI1C/8yB5AcaED0RyaVbQzT0Ajuz0TM4hmo=";
      url = "https://src.fedoraproject.org/rpms/gitg/raw/630cf1bdb50ad37fb20b81d76caa8622e7225c58/f/gitg-gir-2.0.patch";
    })
  ];

  postPatch = ''
    patchShebangs meson_post_install.py

    substituteInPlace tests/libgitg/test-commit.vala --replace-fail "/bin/bash" "${bash}/bin/bash"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gpgme
    gsettings-desktop-schemas
    gtk3
    gtksourceview4
    gspell
    gvfs
    json-glib
    libdazzle
    libgee
    libgit2-glib
    libhandy
    libpeas
    libsecret
    libxml2
  ];

  doCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gitg";
    };
  };

  meta = {
    description = "GNOME GUI client to view git repositories";
    homepage = "https://gitlab.gnome.org/GNOME/gitg";
    changelog = "https://gitlab.gnome.org/GNOME/gitg/-/blob/v${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Luflosi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gitg";
  };
})
