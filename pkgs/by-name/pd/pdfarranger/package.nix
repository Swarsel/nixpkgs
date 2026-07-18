{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  gtk3,
  libhandy,
  poppler_gi,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pdfarranger";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "pdfarranger";
    repo = "pdfarranger";
    tag = finalAttrs.version;
    hash = "sha256-vucl04ltyAFUhwGlFfNnLEyvX2SACEt0WCG3t4QLuxc=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    LINTL="${lib.getLib gettext}/lib/libintl.8.dylib"
    substituteInPlace pdfarranger/pdfarranger.py --replace-fail \
      "return 'libintl.8.dylib'" \
      "return '$LINTL'"
    unset LINTL
  '';

  # incompatible with wrapGAppsHook3
  strictDeps = false;
  nativeBuildInputs = [ wrapGAppsHook3 ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ gettext ];

  buildInputs = [
    gtk3
    poppler_gi
    libhandy
  ];

  doCheck = false; # no tests
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    pikepdf
    img2pdf
    setuptools
    python-dateutil
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Merge or split pdf documents and rotate, crop and rearrange their pages using a graphical interface";
    changelog = "https://github.com/pdfarranger/pdfarranger/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      symphorien
      endle
    ];

    mainProgram = "pdfarranger";
  };
})
