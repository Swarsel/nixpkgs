{
  lib,
  fetchFromGitHub,
  python3Packages,
  xrdb,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "posting";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "darrenburns";
    repo = "posting";
    tag = finalAttrs.version;
    hash = "sha256-4L/MfXd6JYk2Viam9/gegpCkwrNWbK7A05Jnu/SedYs=";
  };

  # Required for x resources themes
  buildInputs = [
    xrdb
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies =
    with python3Packages;
    [
      click
      xdg-base-dirs
      click-default-group
      pyperclip
      pyyaml
      python-dotenv
      watchfiles
      pydantic
      pydantic-settings
      httpx
      textual-autocomplete
      textual
      openapi-pydantic
      tree-sitter-json
      tree-sitter-html
    ]
    ++ httpx.optional-dependencies.brotli
    ++ textual.optional-dependencies.syntax;

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "Modern API client that lives in your terminal";
    homepage = "https://posting.sh/";
    changelog = "https://github.com/darrenburns/posting/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jorikvanveen
      fullmetalsheep
    ];

    platforms = lib.platforms.unix;
    mainProgram = "posting";
  };
})
