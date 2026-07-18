{
  lib,
  stdenv,
  fetchFromGitLab,
  feedbackd,
  json-glib,
  meson,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "feedbackd-device-themes";
  version = "0.8.8";

  src = fetchFromGitLab {
    owner = "agx";
    repo = "feedbackd-device-themes";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EZpzqEhUeqqe96qcfKyvhQodBTcsgwNZyXvk2zHj20k=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    json-glib # Provides json-glib-validate
  ];

  mesonFlags = [
    (lib.mesonOption "validate" (if finalAttrs.doCheck then "enabled" else "disabled"))
  ];

  doCheck = true;

  nativeCheckInputs = [
    feedbackd # Provides fbd-theme-validate
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Device specific feedback themes for Feedbackd";
    homepage = "https://gitlab.freedesktop.org/agx/feedbackd-device-themes";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      pacman99
      Luflosi
    ];

    platforms = lib.platforms.linux;
  };
})
