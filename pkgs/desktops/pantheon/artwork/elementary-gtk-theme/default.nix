{
  lib,
  fetchFromGitHub,
  gettext,
  meson,
  ninja,
  nix-update-script,
  python3,
  sassc,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "elementary-gtk-theme";
  version = "8.2.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "stylesheet";
    rev = version;
    sha256 = "sha256-ZjeufUC3Eg1do3GKN1kW/EceuWfAsFnOkSCmscL+vxg=";
  };

  postPatch = ''
    chmod +x meson/install-to-dir.py
    patchShebangs meson/install-to-dir.py
  '';

  nativeBuildInputs = [
    gettext
    meson
    ninja
    python3
    sassc
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "GTK theme designed to be smooth, attractive, fast, and usable";
    homepage = "https://github.com/elementary/stylesheet";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
