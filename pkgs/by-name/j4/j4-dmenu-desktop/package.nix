{
  lib,
  stdenv,
  fetchFromGitHub,
  dmenu,
  fmt,
  meson,
  ninja,
  pkg-config,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "j4-dmenu-desktop";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "enkore";
    repo = "j4-dmenu-desktop";
    rev = "r${finalAttrs.version}";
    hash = "sha256-Yrn6d2x9xOSV5FK0YP/mfD6BG9DeWlWobVafEzVYVJY=";
  };

  postPatch = ''
    substituteInPlace src/main.cc \
        --replace "dmenu -i" "${lib.getExe dmenu} -i"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    fmt
    spdlog
  ];

  mesonFlags = [
    # Disable unit tests.
    "-Denable-tests=false"
    # Copy pre-generated shell completions.
    "-Dgenerate-shell-completions=disabled"
  ];

  meta = {
    description = "Wrapper for dmenu that recognizes .desktop files";
    homepage = "https://github.com/enkore/j4-dmenu-desktop";
    changelog = "https://github.com/enkore/j4-dmenu-desktop/blob/${finalAttrs.src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "j4-dmenu-desktop";
  };
})
