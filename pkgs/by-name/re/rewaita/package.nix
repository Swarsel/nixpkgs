{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
let
  version = "1.1.1";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "rewaita";

  src = fetchFromGitHub {
    owner = "SwordPuffin";
    repo = "Rewaita";
    tag = "v${version}";
    hash = "sha256-T9GQuhMkCEUFX2BpTTQ+zKhDpSxtVKuncITtm7nqzyY=";
  };

  postPatch = ''
    substituteInPlace src/window.py \
      --replace-fail 'shutil.copy(' 'shutil.copyfile('
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    glib
    gtk4
    desktop-file-utils
    appstream-glib
    blueprint-compiler
  ];

  buildInputs = [
    libadwaita
    gtk4
    libportal-gtk4
    gtksourceview5
  ];

  dependencies = with python3Packages; [
    pygobject3
    pillow
    numpy
    fortune
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bring color to Adwaita";
    homepage = "https://github.com/SwordPuffin/Rewaita";
    changelog = "https://github.com/SwordPuffin/Rewaita/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      da157
      getchoo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "rewaita";
  };
}
