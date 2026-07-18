{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  cairo,
  fdk_aac,
  freerdp,
  fuse3,
  gdk-pixbuf,
  glib,
  gnome,
  libdrm,
  libei,
  libepoxy,
  libkrb5,
  libnotify,
  libopus,
  libsecret,
  libva,
  libxkbcommon,
  meson,
  ninja,
  nv-codec-headers-11,
  pipewire,
  pkg-config,
  polkit,
  python3,
  shaderc,
  systemd,
  tpm2-tss,
  vulkan-loader,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-remote-desktop";
  version = "50.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-remote-desktop/${lib.versions.major finalAttrs.version}/gnome-remote-desktop-${finalAttrs.version}.tar.xz";
    hash = "sha256-CJBJEZ4fJEL+l3PwKFNlztwgf0y8fOmvOI4VNmjisXE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    asciidoc
    shaderc # for glslc
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    freerdp
    fdk_aac
    tpm2-tss
    fuse3
    gdk-pixbuf # For libnotify
    glib
    libei
    libepoxy
    libdrm
    libkrb5
    libva
    vulkan-loader
    nv-codec-headers-11
    libnotify
    libopus
    libsecret
    libxkbcommon
    pipewire
    systemd
    polkit # For polkit-gobject
  ];

  mesonFlags = [
    "-Dconf_dir=/etc/gnome-remote-desktop"
    "-Dsystemd_user_unit_dir=${placeholder "out"}/lib/systemd/user"
    "-Dsystemd_system_unit_dir=${placeholder "out"}/lib/systemd/system"
    "-Dsystemd_sysusers_dir=${placeholder "out"}/lib/sysusers.d"
    "-Dsystemd_tmpfiles_dir=${placeholder "out"}/lib/tmpfiles.d"
    "-Dtests=false" # Too deep of a rabbit hole.
    # TODO: investigate who should be fixed here.
    "-Dc_args=-I${freerdp}/include/winpr3"
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-remote-desktop"; };
  };

  meta = {
    description = "GNOME Remote Desktop server";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-remote-desktop";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-remote-desktop/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "grdctl";
    teams = [ lib.teams.gnome ];
  };
})
