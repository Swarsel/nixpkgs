{
  lib,
  stdenv,
  fetchFromGitHub,
  libnotify,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gcalcli";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "insanum";
    repo = "gcalcli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FU1EHLQ+/2sOGeeGwONsrV786kHTFfMel7ocBcCe+rI=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace gcalcli/argparsers.py \
      --replace-fail "'notify-send" "'${lib.getExe libnotify}"
  '';

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    argcomplete
    babel
    gflags
    google-api-python-client
    google-auth-oauthlib
    httplib2
    libnotify
    parsedatetime
    platformdirs
    pydantic
    python-dateutil
    truststore
    uritemplate
    vobject
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for Google Calendar";
    homepage = "https://github.com/insanum/gcalcli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nocoolnametom ];
    mainProgram = "gcalcli";
  };
})
