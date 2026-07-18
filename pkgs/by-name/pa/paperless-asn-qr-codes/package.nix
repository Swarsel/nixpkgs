{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "paperless-asn-qr-codes";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "paperless-asn-qr-codes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mCymgzKjLMrwb1AjkfFf1EHTkW1G0y+R3ZbG/6Xd978=";
  };

  build-system = [
    python3.pkgs.hatch-vcs
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    reportlab
    reportlab-qrcode
  ];

  pyproject = true;
  pythonImportsCheck = [ "paperless_asn_qr_codes" ];

  pythonRelaxDeps = [
    "reportlab"
  ];

  meta = {
    description = "Command line utility for generating ASN labels for paperless with both a human-readable representation, as well as a QR code for machine consumption";
    homepage = "https://github.com/entropia/paperless-asn-qr-codes";
    changelog = "https://codeberg.org/entropia/paperless-asn-qr-codes/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xanderio ];
    mainProgram = "paperless-asn-qr-codes";
  };
})
