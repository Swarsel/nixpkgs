{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  qt6,
  wayland,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waycheck";
  version = "1.7.0";

  src = fetchFromGitLab {
    owner = "serebit";
    repo = "waycheck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wO3+Vwi4wM/NfRdHUt0AVEE6UPr7wkY12JBVzLFqM4c=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    substituteInPlace scripts/mesonPostInstall.sh \
      --replace-fail "#!/usr/bin/env sh" "#!${stdenv.shell}" \
      --replace-fail "update-desktop-database -q" "update-desktop-database $out/share/applications"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    glib
    wayland
    qt6.qtwayland
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple GUI that displays the protocols implemented by a Wayland compositor";
    homepage = "https://gitlab.freedesktop.org/serebit/waycheck";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      julienmalka
      pandapip1
    ];

    platforms = lib.platforms.linux;
    mainProgram = "waycheck";
  };
})
