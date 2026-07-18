{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  boost,
  cmake,
  fetchpatch,
  glib-networking,
  gmime3,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtkmm3,
  libpeas,
  libsass,
  notmuch,
  pkg-config,
  protobuf,
  python3,
  ronn,
  # vim to be used, should support the GUI mode.
  vim,
  webkitgtk_4_1,
  wrapGAppsHook3,
  # additional python3 packages to be available within plugins
  extraPythonPackages ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astroid";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "astroidmail";
    repo = "astroid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FDStUt989sQXX6kpqStrdjOdAMlLAepcDba9ul9tcps=";
  };

  patches = [
    # Until next version, patch to build with boost 1.89
    (fetchpatch {
      hash = "sha256-QO5hoWscSMcxWLjPn/NT2MaIKrgMvTJeutitm4GaKZY=";
      url = "https://github.com/astroidmail/astroid/commit/b84962a7920aaa9b0cc4a85a0c9fd1802495b1bc.patch";
    })
  ];

  postPatch = ''
    sed -i "s~gvim ~${vim}/bin/vim -g ~g" src/config.cc
    sed -i "s~ -geom 10x10~~g" src/config.cc

    # Switch to girepository-2.0
    substituteInPlace src/plugin/gir_main.c \
      --replace-fail "<girepository.h>" "<girepository/girepository.h>" \
      --replace-fail "g_irepository_get_option_group" "gi_repository_get_option_group"
  '';

  nativeBuildInputs = [
    cmake
    ronn
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    python3
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    gtkmm3
    gmime3
    webkitgtk_4_1
    libsass
    libpeas
    python3
    notmuch
    boost
    gsettings-desktop-schemas
    adwaita-icon-theme
    glib-networking
    protobuf
    vim
  ];

  preFixup = ''
    buildPythonPath "$out ''${pythonPath[*]}"
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$program_PYTHONPATH"
    )
  '';

  pythonPath = with python3.pkgs; requiredPythonModules extraPythonPackages;

  meta = {
    description = "GTK frontend to the notmuch mail system";
    homepage = "https://astroidmail.github.io/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bdimcheff
      SuprDewd
    ];

    platforms = lib.platforms.linux;
    mainProgram = "astroid";
  };
})
