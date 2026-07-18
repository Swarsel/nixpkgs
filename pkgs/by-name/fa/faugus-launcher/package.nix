{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  icoextract,
  imagemagick,
  libayatana-appindicator,
  libcanberra-gtk3,
  lsfg-vk,
  meson,
  ninja,
  nix-update-script,
  python3Packages,
  umu-launcher,
  vulkan-tools,
  wrapGAppsHook3,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "faugus-launcher";
  version = "1.22.8";

  src = fetchFromGitHub {
    owner = "Faugus";
    repo = "faugus-launcher";
    tag = finalAttrs.version;
    hash = "sha256-2FsuD40u5O7VwbziTqhsfVyceyfmSRvdmsizfBy/Xys=";
  };

  postPatch = ''
    substituteInPlace faugus-launcher \
      --replace-fail "/usr/bin/python3" "${python3Packages.python.interpreter}"

    substituteInPlace faugus/path_manager.py \
      --replace-fail "PathManager.user_data('faugus-launcher/umu-run')" "'${lib.getExe umu-launcher}'" \
      --replace-fail "/usr/lib/extensions/vulkan/lsfgvk/lib/liblsfg-vk.so" "${lsfg-vk}/lib/liblsfg-vk.so" \
      --replace-fail "/usr/lib/liblsfg-vk.so" "${lsfg-vk}/lib/liblsfg-vk.so"
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    libayatana-appindicator
  ];

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --suffix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
      --suffix PATH : "${
        lib.makeBinPath [
          icoextract
          imagemagick
          libcanberra-gtk3
          umu-launcher
          vulkan-tools
          xdg-utils
        ]
      }"
    )
    wrapProgram $out/bin/faugus-launcher ''${makeWrapperArgs[@]}
  '';

  dependencies = with python3Packages; [
    pillow
    psutil
    pygame
    pygobject3
    requests
    vdf
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple and lightweight app for running Windows games using UMU-Launcher";
    homepage = "https://github.com/Faugus/faugus-launcher";
    changelog = "https://github.com/Faugus/faugus-launcher/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    platforms = lib.platforms.linux;
    mainProgram = "faugus-launcher";
  };
})
