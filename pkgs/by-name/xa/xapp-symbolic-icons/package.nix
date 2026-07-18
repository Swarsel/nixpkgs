{
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  python3,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "xapp-symbolic-icons";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "xapp-project";
    repo = "xapp-symbolic-icons";
    tag = finalAttrs.version;
    hash = "sha256-cqY0Ck0bOshfpT8VZ7feAiQvrNyPljusRIxLBR4OL5U=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    python3 # xsi-replace-adwaita-symbolic
  ];

  meta = {
    description = "Set of symbolic icons for GTK applications and projects";
    homepage = "https://github.com/xapp-project/xapp-symbolic-icons";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
