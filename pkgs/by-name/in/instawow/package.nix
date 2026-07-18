{
  lib,
  fetchFromGitHub,
  python3,
  plugins ? [ ],
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "instawow";
  version = "7.0.0.post1";

  src = fetchFromGitHub {
    owner = "layday";
    repo = "instawow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z7O3BHi0OECHSJF6v1ran5ALWe9PU4DxPijuN7yQJ+Q=";
  };

  nativeBuildInputs = with python3.pkgs; [
    hatchling
    hatch-vcs
  ];

  propagatedBuildInputs =
    with python3.pkgs;
    [
      aiohttp
      aiohttp-client-cache
      attrs
      cattrs
      click
      diskcache
      iso8601
      loguru
      multidict
      packaging
      pluggy
      prompt-toolkit
      rapidfuzz
      truststore
      typing-extensions
      yarl
    ]
    ++ plugins;

  extras = [ ]; # Disable GUI, most dependencies are not packaged.
  pyproject = true;

  meta = {
    description = "World of Warcraft add-on manager CLI and GUI";
    homepage = "https://github.com/layday/instawow";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ seirl ];
    mainProgram = "instawow";
  };
})
