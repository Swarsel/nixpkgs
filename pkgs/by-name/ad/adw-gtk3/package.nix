{
  lib,
  fetchFromGitHub,
  dart-sass,
  meson,
  ninja,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "adw-gtk3";
  version = "6.5";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = "adw-gtk3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7tCmtSauWUEoQUvOVnL4Zq+Om+9bHUCl1mDUejxjP78=";
  };

  nativeBuildInputs = [
    meson
    ninja
    dart-sass
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial GTK 3 port of libadwaita";
    homepage = "https://github.com/lassekongo83/adw-gtk3";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      ciferkey
      Gliczy
    ];

    platforms = lib.platforms.unix;
  };
})
