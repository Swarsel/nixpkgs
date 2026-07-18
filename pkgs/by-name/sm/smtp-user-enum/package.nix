{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "smtp-user-enum";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "cytopia";
    repo = "smtp-user-enum";
    tag = finalAttrs.version;
    hash = "sha256-2GI//nv87H2zDkkgjAHSx2Zm2Sk0EpxmXQAN+I1K65I=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  pythonRemoveDeps = [
    # https://github.com/cytopia/smtp-user-enum/pull/21
    "argparse"
  ];

  meta = {
    description = "SMTP user enumeration via VRFY, EXPN and RCPT with clever timeout, retry and reconnect functionality";
    homepage = "https://github.com/cytopia/smtp-user-enum";
    changelog = "https://github.com/cytopia/smtp-user-enum/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "smtp-user-enum";
  };
})
