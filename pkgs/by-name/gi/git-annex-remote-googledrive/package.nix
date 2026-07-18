{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-annex-remote-googledrive";
  version = "1.3.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0rwjcdvfgzdlfgrn1rrqwwwiqqzyh114qddrbfwd46ld5spry6r1";
  };

  # while git-annex does come with a testremote command that *could* be used,
  # testing this special remote obviously depends on authenticating with google
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    annexremote
    drivelib
    gitpython
    tenacity
    humanfriendly
    distutils
  ];

  pyproject = true;

  pythonImportsCheck = [
    "git_annex_remote_googledrive"
  ];

  meta = {
    description = "Git-annex special remote for Google Drive";
    homepage = "https://github.com/Lykos153/git-annex-remote-googledrive";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "git-annex-remote-googledrive";
  };
})
