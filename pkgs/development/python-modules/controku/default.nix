{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  gobject-introspection,
  gtk3,
  pygobject3,
  requests,
  setuptools,
  ssdpy,
  wrapGAppsHook3,
  buildApplication ? false,
}:

buildPythonPackage rec {
  pname = "controku";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "benthetechguy";
    repo = "controku";
    rev = version;
    hash = "sha256-sye2GtL3a77pygllZc6ylaIP7faPb+NFbyKKyqJzIXw=";
  };

  nativeBuildInputs = [
    setuptools
  ]
  ++ lib.optionals buildApplication [
    gobject-introspection
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    requests
    ssdpy
  ]
  ++ lib.optionals buildApplication [
    gtk3
    appdirs
    pygobject3
  ];

  pyproject = true;
  pythonImportsCheck = [ "controku" ];

  meta = {
    description = "Control Roku devices from the comfort of your own desktop";
    homepage = "https://github.com/benthetechguy/controku";
    changelog = "https://github.com/benthetechguy/controku/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mjm ];
    mainProgram = "controku";
  };
}
