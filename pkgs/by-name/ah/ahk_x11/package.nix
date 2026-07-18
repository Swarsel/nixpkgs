{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  crystal,
  gobject-introspection, # needed to build gi-crystal
  gtk3,
  libnotify,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxtst,
  nix-update-script,
  openbox,
  versionCheckHook,
  xdotool,
  xvfb-run,
  buildDevTarget ? false, # the dev version prints debug info
}:

# NOTICE: AHK_X11 from this package does not support compiling scripts into portable executables.
let
  pname = "ahk_x11";
  version = "1.0.7";
in
crystal.buildCrystalPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "phil294";
    repo = "AHK_X11";
    tag = version;
    hash = "sha256-VuqLlRgNyF6/4aVq1sNlVjOMih0TdHXbr0CqhA4QT6Y=";
    fetchSubmodules = true;
  };

  # Fix build problems and the following UX problem:
  # Without this patch, the binary launches a graphical installer GUI that is useless with system-wide installation.
  # With this patch, it prompts to use -h for help.
  patches = [ ./adjust.patch ];

  nativeBuildInputs = [
    copyDesktopItems
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libxkbcommon
    libxinerama
    libxtst
    libxext
    libxi
    libnotify
  ];

  preBuild = ''
    mkdir bin
    cd lib/gi-crystal
    shards build -Dpreview_mt --release --no-debug
    cd ../..
    cp lib/gi-crystal/bin/gi-crystal bin
  '';

  postBuild = lib.optionalString buildDevTarget ''
    mv bin/ahk_x11.dev bin/ahk_x11
  '';

  # The tests fail with AtSpi failure. This means it lacks assistive technologies:
  # https://github.com/phil294/AHK_X11?tab=readme-ov-file#accessibility
  # I don't know how to fix it for xvfb and openbox.
  doCheck = false;

  nativeCheckInputs = [
    xvfb-run
    openbox
    xdotool
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    install -Dm644 -t $out/share/licenses/ahk_x11/ LICENSE
    install -Dm644 -t $out/share/icons/hicolor/48x48/apps/ assets/ahk_x11.png
    install -Dm644 -t $out/share/applications/ assets/*.desktop
    install -Dm644 assets/ahk_x11-mime.xml $out/share/mime/packages/ahk_x11.xml
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildTargets = if buildDevTarget then "bin/ahk_x11.dev" else "bin/ahk_x11";
  checkTarget = "test-dev";
  copyShardDeps = true;
  shardsFile = ./shards.nix;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AutoHotkey for X11";
    homepage = "https://phil294.github.io/AHK_X11";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "ahk_x11";
  };
}
