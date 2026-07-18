{
  lib,
  fetchFromGitHub,
  clinfo,
  # buildInputs
  gdk-pixbuf,
  # nativeBuildInputs
  gobject-introspection,
  gtk4,
  libadwaita,
  lsb-release,
  mesa-demos,
  meson,
  ninja,
  # passthru
  nix-update-script,
  pkg-config,
  # wrapper
  python3,
  python3Packages,
  vdpauinfo,
  vulkan-tools,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gpu-viewer";
  version = "3.35";

  src = fetchFromGitHub {
    owner = "arunsivaramanneo";
    repo = "gpu-viewer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W8BPtHbOwLZ95bY6ZmAaKS87fh+gOWZIhxjWKqiavag=";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    gtk4
    libadwaita
    vulkan-tools
  ];

  postFixup = ''
    makeWrapper ${python3.interpreter} $out/bin/gpu-viewer \
      --prefix PATH : "${
        lib.makeBinPath [
          clinfo
          lsb-release
          mesa-demos
          vdpauinfo
          vulkan-tools
        ]
      }" \
      --add-flags "$out/share/gpu-viewer/Files/gpu_viewer.py" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --chdir "$out/share/gpu-viewer/Files" \
      ''${makeWrapperArgs[@]} \
      ''${gappsWrapperArgs[@]}
  '';

  __structuredAttrs = true;
  # Prevent double wrapping
  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3Packages; [
    click
    pygobject3
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Front-end to glxinfo, vulkaninfo, clinfo and es2_info";
    homepage = "https://github.com/arunsivaramanneo/GPU-Viewer";
    changelog = "https://github.com/arunsivaramanneo/GPU-Viewer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
    mainProgram = "gpu-viewer";
  };
})
