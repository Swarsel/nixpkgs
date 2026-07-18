{
  lib,
  fetchFromGitHub,
  aspellDicts,
  buildEnv,
  fetchzip,
  python3Packages,
  qt6,
  # Use `lib.collect lib.isDerivation aspellDicts;` to make all dictionaries
  # available.
  enchantAspellDicts ? with aspellDicts; [
    en
    en-computers
  ],
}:

python3Packages.buildPythonApplication rec {
  pname = "retext";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "retext-project";
    repo = "retext";
    tag = version;
    hash = "sha256-npQ1eVb2iyswbqxi262shC9u/g9oE0ofkLbisFgqQM4=";
  };

  # disable wheel check
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "self.root and self.root.endswith('/wheel')" "False"
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    qt6.qttools.dev
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
  ];

  preConfigure = ''
    lrelease ReText/locale/*.ts
  '';

  doCheck = false;

  postInstall = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    makeWrapperArgs+=(
      "--set" "ASPELL_CONF" "dict-dir ${
        buildEnv {
          name = "aspell-all-dicts";
          paths = map (path: "${path}/lib/aspell") enchantAspellDicts;
        }
      }"
    )

    cp ${toolbarIcons}/* $out/${python3Packages.python.sitePackages}/ReText/icons

    substituteInPlace $out/share/applications/me.mitya57.ReText.desktop \
      --replace-fail "Exec=retext-${version}.data/scripts/retext %F" "Exec=retext %F" \
      --replace-fail "Icon=./ReText/icons/retext.svg" "Icon=retext"
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    chardet
    docutils
    markdown
    markups
    pyenchant
    pygments
    pyqt6
    pyqt6-webengine
  ];

  # prevent double wrapping
  dontWrapQtApps = true;
  pyproject = true;

  pythonImportsCheck = [
    "ReText"
  ];

  toolbarIcons = fetchzip {
    hash = "sha256-nqKAUg9nTzGPPxr80KTn6JX9JgCUJwpcwp8aOIlcxPY=";
    url = "https://github.com/retext-project/retext/archive/icons.zip";
  };

  meta = {
    description = "Editor for Markdown and reStructuredText";
    homepage = "https://github.com/retext-project/retext/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ klntsky ];
    platforms = lib.platforms.unix;
    mainProgram = "retext";
  };
}
