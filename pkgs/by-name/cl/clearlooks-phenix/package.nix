{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clearlooks-phenix";
  version = "7.1";

  src = fetchzip {
    url = "https://github.com/jpfleury/clearlooks-phenix/archive/${finalAttrs.version}.tar.gz";
    sha256 = "sha256-UJgKPoNcpBkIxITAIn3INsANJn/hD8l9NCr/entbZx8=";
  };

  installPhase = ''
    mkdir -p $out/share/themes/Clearlooks-Phenix
    cp -r . $out/share/themes/Clearlooks-Phenix/
  '';

  dontBuild = true;
  preferLocalBuild = true;

  meta = {
    description = "GTK3 port of the Clearlooks theme";

    longDescription = ''
      The Clearlooks-Phénix project aims at creating a GTK3 port of Clearlooks,
      the default theme for Gnome 2. Style is also included for GTK2, Unity and
      for Metacity, Openbox and Xfwm4 window managers.
    '';

    homepage = "https://github.com/jpfleury/clearlooks-phenix";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.prikhi ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/jpfleury/clearlooks-phenix/releases";
  };
})
