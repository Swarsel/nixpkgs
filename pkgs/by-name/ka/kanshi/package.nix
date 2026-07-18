{
  lib,
  stdenv,
  fetchFromGitLab,
  libscfg,
  libvarlink,
  meson,
  ninja,
  pkg-config,
  scdoc,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kanshi";
  version = "1.8.0";

  src = fetchFromGitLab {
    owner = "emersion";
    repo = "kanshi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-90FnVtiYR8AEAddIQe9sfgQDMO8OqlQ8fNy/nJsbhKs=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    wayland
    libvarlink
    libscfg
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Dynamic display configuration tool";

    longDescription = ''
      kanshi allows you to define output profiles that are automatically enabled
      and disabled on hotplug. For instance, this can be used to turn a laptop's
      internal screen off when docked.

      kanshi can be used on Wayland compositors supporting the
      wlr-output-management protocol.
    '';

    homepage = "https://gitlab.freedesktop.org/emersion/kanshi";
    changelog = "https://gitlab.freedesktop.org/emersion/kanshi/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      balsoft
      danielbarter
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "kanshi";
  };
})
