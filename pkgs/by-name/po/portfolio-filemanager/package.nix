{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gettext,
  gobject-introspection,
  gtk3,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "portfolio";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "tchx84";
    repo = "Portfolio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KlFRgBXEoIF/UqZKSAC/oQ+OQBrl40NIXV+49jBq430=";
  };

  postPatch = ''
    patchShebangs build-aux/meson
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    gobject-introspection
    gtk3 # For gtk-update-icon-cache
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  checkPhase = ''
    meson test
  '';

  postInstall = ''
    ln -s dev.tchx84.Portfolio "$out/bin/portfolio"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Prevent double wrapping
  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Minimalist file manager for those who want to use Linux mobile devices";
    homepage = "https://github.com/tchx84/Portfolio";
    changelog = "https://github.com/tchx84/Portfolio/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      dotlambda
      chuangzhu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "dev.tchx84.Portfolio";
  };
})
