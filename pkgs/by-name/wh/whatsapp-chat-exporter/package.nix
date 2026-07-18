{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  version = "0.13.0";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "whatsapp-chat-exporter";

  src = fetchFromGitHub {
    owner = "KnugiHK";
    repo = "Whatsapp-Chat-Exporter";
    tag = version;
    hash = "sha256-nD8rpA1BbKbHpjAuIDdhaiMUjQCypDuo0pNAYbkoOxo=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    bleach
    javaobj-py3
    jinja2
    pycryptodome
    tqdm
  ];

  pyproject = true;

  meta = {
    description = "WhatsApp database parser";

    longDescription = ''
      A customizable Android and iPhone WhatsApp database parser that will give
      you the history of your WhatsApp conversations inHTML and JSON. Android
      Backup Crypt12, Crypt14 and Crypt15 supported.
    '';

    homepage = "https://github.com/KnugiHK/Whatsapp-Chat-Exporter";
    changelog = "https://github.com/KnugiHK/Whatsapp-Chat-Exporter/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bbenno
    ];

    mainProgram = "wtsexporter";
  };
}
