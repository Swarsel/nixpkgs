{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "contact";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "pdxlocations";
    repo = "contact";
    tag = finalAttrs.version;
    hash = "sha256-YNDw/lAPuJIyK6abRnl5WOyv8+t/PTtmBvFWu7NTVwY=";
  };

  build-system = [ python3Packages.poetry-core ];
  dependencies = [ python3Packages.meshtastic ];
  pyproject = true;

  meta = {
    description = "Console UI for Meshtastic";
    homepage = "https://github.com/pdxlocations/contact";
    changelog = "https://github.com/pdxlocations/contact/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      sarcasticadmin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "contact";
  };
})
