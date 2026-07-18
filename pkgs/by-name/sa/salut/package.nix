{
  lib,
  fetchFromGitLab,
  fontconfig,
  libxkbcommon,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage {
  pname = "salut";
  version = "unstable-2022-12-17";

  src = fetchFromGitLab {
    owner = "snakedye";
    repo = "salut";
    rev = "aa57c4d190812908a9c32cd49cff14390c6dfdcb";
    hash = "sha256-W0lhhImSXtYJDeMbxyEioYu/Bh7ZclwR1/5DzNbxM8o=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    libxkbcommon
    wayland
  ];

  cargoHash = "sha256-xqj9USqVG7g2zT2P3VxDVt8fFDtyUnZOdT6gYZh4cRI=";

  meta = {
    description = "Sleek notification daemon for Wayland";
    homepage = "https://gitlab.com/snakedye/salut/-/wikis/Home";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "salut";
  };
}
