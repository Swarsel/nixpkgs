{
  lib,
  fetchPypi,
  gobject-introspection,
  python3Packages,
  wrapGAppsNoGuiHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gnome-extensions-cli";
  version = "0.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-5OL0ma17rXA+USDATVQXO3ORWDAwoGB3x85BSIsRapY=";
    pname = "gnome_extensions_cli";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.colorama
    python3Packages.packaging
    python3Packages.pydantic
    python3Packages.requests
    python3Packages.pygobject3
    python3Packages.tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gnome_extensions_cli"
  ];

  pythonRelaxDeps = [
    "more-itertools"
    "packaging"
  ];

  meta = {
    description = "Command line tool to manage your GNOME Shell extensions";
    homepage = "https://github.com/essembeh/gnome-extensions-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dylanmtaylor ];
    platforms = lib.platforms.linux;
  };
})
