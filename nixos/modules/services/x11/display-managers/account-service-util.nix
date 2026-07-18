{
  lib,
  accountsservice,
  glib,
  gobject-introspection,
  python3,
  wrapGAppsNoGuiHook,
}:

python3.pkgs.buildPythonApplication {
  buildInputs = [
    accountsservice
    glib
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/set-session
    chmod +x $out/bin/set-session
  '';

  name = "set-session";

  nativeBuildInputs = [
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    ordered-set
  ];

  pyproject = false;
  src = ./set-session.py;
  strictDeps = false;

  meta = {
    teams = [ lib.teams.pantheon ];
  };
}
