{
  lib,
  fetchPypi,
  nix-update-script,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "signal-export";
  version = "3.8.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-V6yo1nimjQJgbf17A/RSe/vykfCxcFFL0xZaQY3k0Tk=";
    pname = "signal_export";
  };

  propagatedBuildInputs = with python3.pkgs; [
    typer
    beautifulsoup4
    emoji
    markdown
    pycryptodome
    sqlcipher3-wheels
  ];

  build-system = with python3.pkgs; [
    pdm-backend
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Export your Signal chats to markdown files with attachments";
    homepage = "https://github.com/carderne/signal-export";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      phaer
      picnoir
    ];

    platforms = lib.platforms.unix;
    mainProgram = "sigexport";
  };
})
