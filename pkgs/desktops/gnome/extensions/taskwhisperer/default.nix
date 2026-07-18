{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  replaceVars,
  runtimeShell,
  taskwarrior2,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-taskwhisperer";
  version = "20";

  src = fetchFromGitHub {
    owner = "cinatic";
    repo = "taskwhisperer";
    rev = "v${version}";
    sha256 = "sha256-UVBLFXsbOPRXC4P5laZ82Rs08yXnNnzJ+pp5fbx6Zqc=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      task = "${taskwarrior2}/bin/task";
    })
  ];

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    taskwarrior2
  ];

  makeFlags = [
    "INSTALLBASE=${placeholder "out"}/share/gnome-shell/extensions"
  ];

  passthru = {
    extensionPortalSlug = "taskwhisperer";
    extensionUuid = "taskwhisperer-extension@infinicode.de";
  };

  meta = {
    description = "GNOME Shell TaskWarrior GUI";
    homepage = "https://github.com/cinatic/taskwhisperer";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
