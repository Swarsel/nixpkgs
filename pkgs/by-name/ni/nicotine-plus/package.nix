{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  python3Packages,
  wrapGAppsHook4,
}:
let

  pname = "nicotine-plus";
  version = "3.3.10";
in
python3Packages.buildPythonApplication {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "nicotine-plus";
    repo = "nicotine-plus";
    tag = version;
    hash = "sha256-ic/+Us56UewMjD8vgmxxCisoId96Qtaq8/Ll+CCFR3Y=";
  };

  nativeBuildInputs = [
    gettext
    wrapGAppsHook4
    gobject-introspection
    glib
    gdk-pixbuf
    gtk4
  ];

  buildInputs = [
    libadwaita
  ];

  doCheck = false;

  postInstall = ''
    ln -s $out/bin/nicotine $out/bin/nicotine-plus
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pygobject3
  ];

  dontWrapGAppsHook = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = true;

  meta = {
    description = "Graphical client for the SoulSeek peer-to-peer system";

    longDescription = ''
      Nicotine+ aims to be a pleasant, free and open source (FOSS) alternative
      to the official Soulseek client, providing additional functionality while
      keeping current with the Soulseek protocol.
    '';

    homepage = "https://www.nicotine-plus.org";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      klntsky
      amadaluzia
    ];
  };
}
