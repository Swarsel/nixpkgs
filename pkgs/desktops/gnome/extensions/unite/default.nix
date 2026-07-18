{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gnome-shell,
  xprop,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-unite";
  version = "84";

  src = fetchFromGitHub {
    owner = "hardpixel";
    repo = "unite-shell";
    rev = "v${version}";
    hash = "sha256-ZaZs+PqnwMHfCejPt4wBZttT4J5gUlFQ8NjhaOPWGqQ=";
  };

  nativeBuildInputs = [ glib ];
  buildInputs = [ xprop ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict --targetdir="unite@hardpixel.eu/schemas/" "unite@hardpixel.eu/schemas"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions
    cp -r "unite@hardpixel.eu" $out/share/gnome-shell/extensions
    runHook postInstall
  '';

  passthru = {
    extensionPortalSlug = "unite";
    extensionUuid = "unite@hardpixel.eu";
  };

  meta = {
    description = "Unite is a GNOME Shell extension which makes a few layout tweaks to the top panel and removes window decorations to make it look like Ubuntu Unity Shell";
    homepage = "https://github.com/hardpixel/unite-shell";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rhoriguchi ];
    broken = lib.versionOlder gnome-shell.version "3.32";
  };
}
