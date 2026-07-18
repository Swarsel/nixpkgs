{
  lib,
  fetchFromSourcehut,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mymcplus";
  version = "3.0.5";

  src = fetchFromSourcehut {
    owner = "~thestr4ng3r";
    repo = "mymcplus";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-GFReOgM8zi5oyePpJm5HxtizUVqqUUINTRwyG/LGWB8=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyopengl
    wxpython
  ];

  pyproject = true;
  pythonImportsCheck = [ "mymcplus" ];

  meta = {
    description = "PlayStation 2 memory card manager";
    homepage = "https://git.sr.ht/~thestr4ng3r/mymcplus";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "mymcplus";
  };
})
