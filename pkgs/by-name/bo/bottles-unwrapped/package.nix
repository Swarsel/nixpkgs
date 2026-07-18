{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  cabextract,
  desktop-file-utils,
  fvs2,
  gamemode,
  gamescope,
  gtk4,
  gtksourceview5,
  imagemagick,
  libadwaita,
  libportal,
  librsvg,
  lsb-release,
  mangohud,
  meson,
  ninja,
  nix-update-script,
  p7zip,
  pciutils,
  pkg-config,
  procps,
  python3Packages,
  vkbasalt-cli,
  vmtouch,
  vulkan-tools,
  wrapGAppsHook4,
  xdpyinfo,
  removeWarningPopup ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bottles-unwrapped";
  version = "64.1";

  src = fetchFromGitHub {
    owner = "bottlesdevs";
    repo = "bottles";
    tag = finalAttrs.version;
    hash = "sha256-RwH2XLY9PmyDvIYu3Wr2qL89ErJBfC58i0jHLLNnKJQ=";
  };

  patches = [
    ./vulkan_icd.patch
    ./redirect-bugtracker.patch
    ./remove-flatpak-check.patch
  ]
  ++ (
    if removeWarningPopup then
      [ ./remove-unsupported-warning.patch ]
    else
      [
        ./warn-unsupported.patch
      ]
  );

  # https://github.com/bottlesdevs/Bottles/wiki/Packaging
  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gtk4 # gtk4-update-icon-cache
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    librsvg
    gtk4
    gtksourceview5
    libadwaita
    libportal
  ];

  propagatedBuildInputs =
    with python3Packages;
    [
      pyyaml
      pycurl
      chardet
      requests
      markdown
      icoextract
      patool
      pathvalidate
      orjson
      pycairo
      pygobject3
      charset-normalizer
      idna
      urllib3
      certifi
      pefile
      yara-python
    ]
    ++ [
      cabextract
      p7zip
      xdpyinfo
      imagemagick
      vkbasalt-cli
      vulkan-tools

      gamemode
      gamescope
      mangohud
      vmtouch
      fvs2

      # Undocumented (subprocess.Popen())
      lsb-release
      pciutils
      procps
    ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true; # prevent double wrapping
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy-to-use wineprefix manager";
    homepage = "https://usebottles.com/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      psydvl
      Gliczy
      XBagon
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bottles";
    downloadPage = "https://github.com/bottlesdevs/Bottles/releases";
  };
})
