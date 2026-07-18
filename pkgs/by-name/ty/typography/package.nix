{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  desktop-file-utils,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "typography";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "design";
    repo = "typography";
    tag = finalAttrs.version;
    hash = "sha256-XAoqB3Gvd/sRrbM4m5s3aYia7bZgPB9UEJ26Bzkj8Ws=";
    domain = "gitlab.gnome.org";
    forceFetchGit = true;
    group = "World";
  };

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libadwaita
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for looking up text styles";
    homepage = "https://gitlab.gnome.org/World/design/typography";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = lib.platforms.linux;
    mainProgram = "org.gnome.design.Typography";
  };
})
