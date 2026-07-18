{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  markdown,
}:

buildPythonPackage (finalAttrs: {
  pname = "obsidian-media";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "GooRoo";
    repo = "obsidian-media";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+JerHkpQExP2ytYFFxNbsvAJInUqVg/483KtywP38/g=";
  };

  # No tests are available
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    markdown
  ];

  pyproject = true;

  pythonImportsCheck = [
    "obsidian_media"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/GooRoo/obsidian-media";

    license = with lib.licenses; [
      bsd3
      cc0
    ];

    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "obsidian-media";
  };
})
