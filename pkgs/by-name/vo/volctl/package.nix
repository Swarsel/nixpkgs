{
  lib,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  gtk3,
  libpulseaudio,
  libxfixes,
  pango,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "volctl";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "buzz";
    repo = "volctl";
    rev = "v${version}";
    sha256 = "sha256-zL1m/DeSOrNkjt9B+8pdy2jUgjSp7tt81UpAueGsIwQ=";
  };

  postPatch = ''
    substituteInPlace volctl/xwrappers.py \
      --replace 'libXfixes.so' "${libxfixes}/lib/libXfixes.so" \
      --replace 'libXfixes.so.3' "${libxfixes}/lib/libXfixes.so.3"
  '';

  # with strictDeps importing "gi.repository.Gtk" fails with "gi.RepositoryError: Typelib file for namespace 'Pango', version '1.0' not found"
  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    pango
    gtk3
  ]
  ++ (with python3Packages; [
    pulsectl
    click
    pycairo
    pygobject3
    pyyaml
  ]);

  preBuild = ''
    export LD_LIBRARY_PATH=${libpulseaudio}/lib
  '';

  # no tests included
  doCheck = false;

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${libpulseaudio}/lib")
  '';

  format = "setuptools";
  pythonImportsCheck = [ "volctl" ];

  meta = {
    description = "PulseAudio enabled volume control featuring per-app sliders";
    homepage = "https://buzz.github.io/volctl/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "volctl";
  };
}
