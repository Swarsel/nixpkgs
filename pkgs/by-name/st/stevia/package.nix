{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  cmake,
  dconf,
  feedbackd,
  fzf,
  glib,
  gmobile,
  gnome-desktop,
  gtk3,
  hunspell,
  json-glib,
  libhandy,
  libxkbcommon,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  systemd,
  wayland-scanner,
  wrapGAppsHook3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "stevia";
  version = "0.54.0";

  src = fetchFromGitLab {
    owner = "World/Phosh";
    repo = "stevia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eCM2PSn0sDnL7iDbgt6phQsGmdeBfkVjOkxt42WxyXo=";
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
  };

  postPatch = ''
    patchShebangs --build tools/write-layout-info.py
  '';

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
    python3
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    appstream
    feedbackd
    fzf
    glib.dev
    gmobile
    gnome-desktop
    gtk3
    hunspell
    json-glib
    libhandy
    libxkbcommon
    systemd
    dconf
  ];

  mesonFlags = [
    "-Dc_args=-I${glib.dev}/include/gio-unix-2.0"
    "-Dsystemd_user_unit_dir=${placeholder "out"}/lib/systemd/user"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "User friendly on screen keyboard for Phosh";
    homepage = "https://gitlab.gnome.org/World/Phosh/stevia";
    changelog = "https://gitlab.gnome.org/World/Phosh/stevia/-/releases/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Plus ];

    maintainers = with lib.maintainers; [
      ungeskriptet
      armelclo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "phosh-osk-stevia";
  };
})
