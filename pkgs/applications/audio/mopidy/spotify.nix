{
  lib,
  fetchFromGitHub,
  mopidy,
  nix-update-script,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-spotify";
  version = "5.0.0a3";

  src = fetchFromGitHub {
    owner = "mopidy";
    repo = "mopidy-spotify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pM+kqeWYiPXv9DZDBTgwiEwC6Sbqv6uz5vJ5odcixOw=";
  };

  nativeCheckInputs = [
    pythonPackages.pytestCheckHook
    pythonPackages.responses
  ];

  build-system = [ pythonPackages.setuptools ];

  dependencies = [
    mopidy
    pythonPackages.pykka
    pythonPackages.requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_spotify" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Mopidy extension for playing music from Spotify";
    homepage = "https://github.com/mopidy/mopidy-spotify";
    changelog = "https://github.com/mopidy/mopidy-spotify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ getchoo ];
  };
})
