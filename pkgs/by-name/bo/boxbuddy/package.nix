{
  lib,
  fetchFromGitHub,
  distrobox,
  libadwaita,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "boxbuddy";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "Dvlv";
    repo = "BoxBuddyRS";
    tag = finalAttrs.version;
    hash = "sha256-9BGgm4yRjCarJIGP/G9gPj/qsYWb96XGJmpgLj3XCdM=";
  };

  # The software assumes it is installed either in flatpak or in the home directory
  # so the xdg data path needs to be patched here
  postPatch = ''
    substituteInPlace src/utils.rs \
      --replace-fail '{data_home}/locale' "$out/share/locale" \
      --replace-fail '{data_home}/icons/boxbuddy/{icon}' "$out/share/icons/boxbuddy/{icon}"
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  cargoHash = "sha256-2ipLO2b/mEEwSl0PSCq6m9tBhhaiDj9mXXVO4pr/78c=";
  doCheck = false; # No checks defined

  postInstall = ''
    cp icons/* ./
    XDG_DATA_HOME=$out/share INSTALL_DIR=$out ./scripts/install.sh
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ distrobox ]}
    )
  '';

  meta = {
    description = "Unofficial GUI for managing your Distroboxes, written with GTK4 + Libadwaita";
    homepage = "https://dvlv.github.io/BoxBuddyRS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "boxbuddy-rs";
  };
})
