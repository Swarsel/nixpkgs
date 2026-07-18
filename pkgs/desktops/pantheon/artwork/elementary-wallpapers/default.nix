{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  meson,
  ninja,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "elementary-wallpapers";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wallpapers";
    rev = version;
    sha256 = "sha256-qbqYr+3Vqwi1UBD0fRW6lI2rj5Iy51taZRGxDTpKfpg=";
  };

  postPatch = ''
    chmod +x meson/symlink.py
    patchShebangs meson/symlink.py
  '';

  nativeBuildInputs = [
    gettext
    meson
    ninja
    python3
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Collection of wallpapers for elementary";
    homepage = "https://github.com/elementary/wallpapers";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
