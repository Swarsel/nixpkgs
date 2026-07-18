{
  lib,
  stdenv,
  fetchurl,
  dbus,
  dbus-glib,
  fortune,
  gdk-pixbuf,
  gtk3,
  librsvg,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xcowsay";
  version = "1.6";

  src = fetchurl {
    url = "https://www.nickg.me.uk/files/xcowsay-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-RqzoZP8o0tIfS3BY8CleGNAEGhIMEHipUfpDxOD1yMU=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    dbus
    dbus-glib
    gtk3
    gdk-pixbuf # loading cow images
    librsvg # dreaming SVG images
  ];

  configureFlags = [ "--enable-dbus" ];

  postInstall = ''
    for tool in xcowdream xcowsay xcowthink xcowfortune; do
      wrapProgram $out/bin/$tool \
        --prefix PATH : $out/bin:${fortune}/bin
    done
  '';

  meta = {
    description = "Tool to display a cute cow and messages";
    homepage = "https://www.doof.me.uk/xcowsay";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ das_j ];
  };
})
