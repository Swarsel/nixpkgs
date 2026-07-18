{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "serigy";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "CleoMenezesJr";
    repo = "Serigy";
    tag = finalAttrs.version;
    hash = "sha256-WOourIlF2Z1YP34d9VCuX7kysJxeMBz2enOaGu73r8o=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
    pkg-config
  ];

  buildInputs = [ libadwaita ];
  dependencies = with python3Packages; [ pygobject3 ];
  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # uses meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Store important information from your clipboard selectively and securely";
    homepage = "https://github.com/CleoMenezesJr/Serigy";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "serigy";
  };
})
