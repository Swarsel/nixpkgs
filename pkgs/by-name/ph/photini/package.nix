{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "photini";
  version = "2024.9.1";

  src = fetchFromGitHub {
    owner = "jim-easterbrook";
    repo = "Photini";
    tag = finalAttrs.version;
    hash = "sha256-0jr1mNejCF0yW9LkrrsOTcE4ZPGZrMU9Pnt0eXD+3YQ=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    pyside6
    cachetools
    appdirs
    chardet
    exiv2
    filetype
    requests
    requests-oauthlib
    requests-toolbelt
    pyenchant
    gpxpy
    keyring
    pillow
    toml
  ];

  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Easy to use digital photograph metadata (Exif, IPTC, XMP) editing application";
    homepage = "https://github.com/jim-easterbrook/Photini";
    changelog = "https://photini.readthedocs.io/en/release-${finalAttrs.version}/misc/changelog.html";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zebreus ];
    mainProgram = "photini";
  };
})
