{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "instaloader";
  version = "4.14.2";

  src = fetchFromGitHub {
    owner = "instaloader";
    repo = "instaloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q5/lZ+BHnrod0vG/ZJw/5iJRKKaP3Gbns5yaZH0P2rE=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.requests
    python3Packages.sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "instaloader" ];

  meta = {
    description = "Download pictures (or videos) along with their captions and other metadata from Instagram";
    homepage = "https://instaloader.github.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ creator54 ];
    mainProgram = "instaloader";
  };
})
