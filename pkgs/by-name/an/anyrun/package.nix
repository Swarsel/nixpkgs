{
  lib,
  fetchFromGitHub,
  anyrun-provider,
  cairo,
  gdk-pixbuf,
  glib,
  gtk4,
  gtk4-layer-shell,
  nix-update-script,
  pango,
  pkg-config,
  rustPlatform,
  wayland,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "anyrun";
  version = "26.6.1";

  src = fetchFromGitHub {
    owner = "anyrun-org";
    repo = "anyrun";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Fx+JfSboBk8KKVgmaMKDKvMe9c3WC+7RKYjnpvMVpg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    gtk4-layer-shell
    pango
    wayland
  ];

  cargoHash = "sha256-NHWKgLvILeXVLyKxfm/uWxb2mwb1wM6Utw9vPlUPYaI=";
  doCheck = true;

  postInstall = ''
    install -Dm444 anyrun/res/style.css examples/config.ron -t $out/share/doc/anyrun/examples/
  '';

  preFixup = ''
    gappsWrapperArgs+=(
     --prefix PATH ":" ${lib.makeBinPath [ anyrun-provider ]}
     --prefix ANYRUN_PLUGINS : $out/lib
    )
  '';

  enableParallelBuilding = true;

  passthru = {
    # This is used for detecting whether or not an Anyrun package has the provider
    inherit anyrun-provider;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland-native, highly customizable runner";
    homepage = "https://github.com/anyrun-org/anyrun";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      khaneliman
      NotAShelf
    ];

    platforms = lib.platforms.linux;
    mainProgram = "anyrun";
  };
})
