{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mastodon-archive";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "kensanata";
    repo = "mastodon-archive";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yz17ddcA0U9fq1aDlPmD3OkNL6Epzdp9C7L+31yNLBc=";
  };

  # There is no test
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    html2text
    mastodon-py
    progress
  ];

  pyproject = true;
  pythonImportsCheck = [ "mastodon_archive" ];

  meta = {
    description = "Utility for backing up your Mastodon content";
    homepage = "https://alexschroeder.ch/software/Mastodon_Archive";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ julm ];
    mainProgram = "mastodon-archive";
  };
})
