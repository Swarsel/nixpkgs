{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gitUpdater,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  upscayl-ncnn,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "upscaler";
  version = "1.6.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Upscaler";
    rev = finalAttrs.version;
    hash = "sha256-h+m5YOnsWFmQH0FxYrGbUzGMr38HhnkHegJl4daRXAs=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace upscaler/window.py \
      --replace-fail '"upscayl-bin",' '"${lib.getExe upscayl-ncnn}",'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook4
    meson
    ninja
    desktop-file-utils
    appstream
    blueprint-compiler
    pkg-config
    gtk4
    glib
  ];

  buildInputs = [
    libadwaita
    upscayl-ncnn
  ];

  mesonFlags = [
    (lib.mesonBool "network_tests" false)
  ];

  dependencies = with python3Packages; [
    pygobject3
    pillow
    vulkan
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  # NOTE: `postCheck` is intentionally not used here, as the entire checkPhase
  # is skipped by `buildPythonApplication`
  # https://github.com/NixOS/nixpkgs/blob/9d4343b7b27a3e6f08fc22ead568233ff24bbbde/pkgs/development/interpreters/python/mk-python-derivation.nix#L296
  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # meson instead of pyproject
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Upscale and enhance images";
    homepage = "https://tesk.page/upscaler";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      grimmauld
      getchoo
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "upscaler";
  };
})
