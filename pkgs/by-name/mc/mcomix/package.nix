{
  lib,
  fetchurl,
  gdk-pixbuf,
  gobject-introspection,
  gtk3,
  mcomix,
  # Recommended Dependencies:
  p7zip,
  python3,
  testers,
  unrar,
  wrapGAppsHook3,
  chardetSupport ? true,
  pdfSupport ? true,
  unrarSupport ? false, # unfree software
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mcomix";
  version = "3.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/mcomix/mcomix-${finalAttrs.version}.tar.gz";
    hash = "sha256-oQqq7XvAfet0796Tv5qKJ+G8vxgkoFGbJkz+5YK+zvg=";
  };

  nativeBuildInputs = [
    gobject-introspection
    python3.pkgs.setuptools
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
  ];

  propagatedBuildInputs =
    with python3.pkgs;
    [
      pillow
      pycairo
      pygobject3
    ]
    ++ lib.optionals chardetSupport [ chardet ]
    ++ lib.optionals pdfSupport [ pymupdf ];

  # No tests included in .tar.gz
  doCheck = false;

  postInstall = ''
    cp -a share $out/
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      "--prefix" "PATH" ":" "${lib.makeBinPath ([ p7zip ] ++ lib.optional unrarSupport unrar)}"
    )
  '';

  # Prevent double wrapping
  dontWrapGApps = true;
  pyproject = true;

  passthru.tests.version = testers.testVersion {
    package = mcomix;
  };

  meta = {
    description = "Comic book reader and image viewer";

    longDescription = ''
      User-friendly, customizable image viewer, specifically designed to handle
      comic books and manga supporting a variety of container formats
      (including CBR, CBZ, CB7, CBT, LHA and PDF)
    '';

    homepage = "https://sourceforge.net/projects/mcomix/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      confus
      thiagokokada
    ];

    mainProgram = "mcomix";
  };
})
