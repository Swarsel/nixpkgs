{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  ibus,
  intltool,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

let
  pythonModules = with python3.pkgs; [
    pygobject3
    pycangjie
    (toPythonModule ibus)
  ];

  # Upstream builds Python packages as a part of a non-python
  # autotools build, making it awkward to rely on Nixpkgs Python builders.
  # Hence we manually set up PYTHONPATH.
  pythonPath = "$out/${python3.sitePackages}" + ":" + python3.pkgs.makePythonPath pythonModules;

in
stdenv.mkDerivation {
  pname = "ibus-cangjie";
  version = "unstable-2023-07-25";

  src = fetchFromGitHub {
    owner = "Cangjians";
    repo = "ibus-cangjie";
    rev = "46c36f578047bb3cb2ce777217abf528649bc58d";
    sha256 = "sha256-msVqWougc40bVXIonJA6K/VgurnDeR2TdtGKfd9rzwM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    gettext
    gobject-introspection
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    ibus
    python3
  ]
  ++ pythonModules;

  # Upstream builds Python packages as a part of a non-python
  # autotools build, making it awkward to rely on Nixpkgs Python builders.
  postInstall = ''
    gappsWrapperArgs+=(--prefix PYTHONPATH : "${pythonPath}")
  '';

  postFixup = ''
    wrapGApp $out/lib/ibus-cangjie/ibus-engine-cangjie
  '';

  meta = {
    description = "IBus engine for users of the Cangjie and Quick input methods";
    homepage = "https://github.com/Cangjians/ibus-cangjie";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ibus-setup-cangjie";
    isIbusEngine = true;
  };
}
