{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ascii-draw";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Nokse22";
    repo = "ascii-draw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AwcOFqPWPJoZt3spWdl0AlGZ25aEIhP45EO3pjb14hs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pyfiglet
    emoji
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Draw diagrams or anything using only ASCII";
    homepage = "https://github.com/Nokse22/ascii-draw";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    # gnulib bindtextdomain is missing on various other unix platforms
    platforms = lib.platforms.linux;
    mainProgram = "ascii-draw";
  };
})
