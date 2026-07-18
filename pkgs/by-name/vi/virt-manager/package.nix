{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  dconf,
  desktopToDarwinBundle,
  docutils,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk-vnc,
  gtksourceview4,
  libayatana-appindicator,
  libosinfo,
  libvirt-glib,
  meson,
  ninja,
  pkg-config,
  python3,
  vte,
  wrapGAppsHook4,
  xorriso,
  gst_all_1 ? null,
  spice-gtk ? null,
  spiceSupport ? true,
}:

let
  pythonDependencies = with python3.pkgs; [
    pygobject3
    libvirt
    libxml2
    requests
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "virt-manager";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "virt-manager";
    repo = "virt-manager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nMWLDo2pfWcqsVuEk0JbzLZ1a0lViTohsZ8gEXGhBuI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection # for setup hook populating GI_TYPELIB_PATH
    docutils
    wrapGAppsHook4
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    python3
    libvirt-glib
    vte
    dconf
    gtk-vnc
    adwaita-icon-theme
    gsettings-desktop-schemas
    libosinfo
    gtksourceview4
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libayatana-appindicator
  ]
  ++ lib.optionals spiceSupport [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    spice-gtk
  ];

  mesonFlags = [
    (lib.mesonBool "compile-schemas" false)
    (lib.mesonEnable "tests" false)
  ];

  postInstall = ''
    if ! grep -q StartupWMClass= "$out/share/applications/virt-manager.desktop"; then
        echo "StartupWMClass=.virt-manager-wrapped" >> "$out/share/applications/virt-manager.desktop"
    else
        echo "error: upstream desktop file already contains StartupWMClass=, please update Nix expr" >&2
        exit 1
    fi
  '';

  preFixup = ''
    glib-compile-schemas $out/share/gsettings-schemas/virt-manager-${finalAttrs.version}/glib-2.0/schemas

    gappsWrapperArgs+=(--set PYTHONPATH "${python3.pkgs.makePythonPath pythonDependencies}")
    # these are called from virt-install in installerinject.py
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ xorriso ]}")

    patchShebangs $out/bin
  '';

  meta = {
    description = "Desktop user interface for managing virtual machines";

    longDescription = ''
      The virt-manager application is a desktop user interface for managing
      virtual machines through libvirt. It primarily targets KVM VMs, but also
      manages Xen and LXC (linux containers).
    '';

    homepage = "https://virt-manager.org";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      fpletz
    ];

    platforms = lib.platforms.unix;
    mainProgram = "virt-manager";
  };
})
