{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  libnotify,
  libportal-gtk4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "coulr";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Huluti";
    repo = "Coulr";
    tag = finalAttrs.version;
    hash = "sha256-ATKD2PmNz8QRIqGHEuNNe8ZGjcvAU8qpqQtXWR2JBSA=";
  };

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
    substituteInPlace build-aux/meson/postinstall.py \
      --replace-fail gtk-update-icon-cache gtk4-update-icon-cache
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    appstream-glib
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libportal-gtk4
    libnotify
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = [ python3.pkgs.pygobject3 ];
  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Color box to help developers and designers";
    homepage = "https://github.com/Huluti/Coulr";
    changelog = "https://github.com/Huluti/Coulr/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jaredmontoya ];
    platforms = lib.platforms.linux;
    mainProgram = "coulr";
  };
})
