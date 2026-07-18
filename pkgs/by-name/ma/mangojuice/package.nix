{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gtk4,
  libadwaita,
  libgee,
  makeBinaryWrapper,
  mangohud,
  mesa-demos,
  meson,
  ninja,
  nix-update-script,
  pciutils,
  pkg-config,
  replaceVars,
  vala,
  vkbasalt,
  vulkan-tools,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mangojuice";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "radiolamp";
    repo = "mangojuice";
    tag = finalAttrs.version;
    hash = "sha256-jlSEPUo2Y84xyIRmUdsIBYzZo7a8wQFOnRbb7oOPeok=";
  };

  patches = [
    (replaceVars ./fix-vkbasalt-path.patch {
      vkbasalt = lib.getLib vkbasalt + "/lib/vkbasalt/libvkbasalt.so";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    glib # For glib-compile-schemas
    vala
    pkg-config
    makeBinaryWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    libgee
  ];

  postFixup =
    let
      path = lib.makeBinPath [
        mangohud
        mesa-demos # glxgears
        pciutils # lspci
        vulkan-tools # vkcube
      ];
    in
    ''
      wrapProgram $out/bin/mangojuice \
        --prefix PATH : ${path} \
        "''${gappsWrapperArgs[@]}"
    '';

  dontWrapGApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convenient alternative to GOverlay for setting up MangoHud";
    homepage = "https://github.com/radiolamp/mangojuice";
    changelog = "https://github.com/radiolamp/mangojuice/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Only ];

    maintainers = with lib.maintainers; [
      pluiedev
      getchoo
    ];

    platforms = lib.platforms.linux;
  };
})
