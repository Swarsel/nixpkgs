{
  lib,
  fetchFromGitHub,
  appdirs,
  arrow,
  borgbackup,
  buildPythonPackage,
  docopt,
  flit-core,
  inform,
  nestedtext,
  parametrize-from-file,
  pytestCheckHook,
  quantiphy,
  requests,
  shlib,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "emborg";
  version = "1.43";

  src = fetchFromGitHub {
    owner = "KenKundert";
    repo = "emborg";
    tag = "v${version}";
    hash = "sha256-b/nzAkWFOGPqr/cMX38WIQaOz7n+9d6gtMIgtFAd+yY=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    appdirs
    arrow
    docopt
    inform
    quantiphy
    requests
  ];

  # this disables testing fuse mounts
  env.MISSING_DEPENDENCIES = "fuse";

  nativeCheckInputs = [
    nestedtext
    parametrize-from-file
    pytestCheckHook
    shlib
    voluptuous
    borgbackup
  ];

  pyproject = true;
  pythonImportsCheck = [ "emborg" ];

  meta = {
    description = "Interactive command line interface to Borg Backup";
    homepage = "https://github.com/KenKundert/emborg";
    changelog = "https://github.com/KenKundert/emborg/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
