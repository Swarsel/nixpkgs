{
  lib,
  fetchFromGitHub,
  bash,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "marcel";
  version = "0.30.4";

  src = fetchFromGitHub {
    owner = "geophile";
    repo = "marcel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ER1Hr+sC55Qnp21qjCwc70Nho2VQ3FztzsLLlx3EtA8=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  buildInputs = [
    bash
  ];

  # The tests use sudo and try to read/write $HOME/.local/share/marcel and /tmp
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/marcel \
      --prefix PATH : "$program_PATH:${lib.getBin bash}/bin" \
      --prefix PYTHONPATH : "$program_PYTHONPATH"
  '';

  pyproject = true;

  pythonPath = with python3Packages; [
    dill
    psutil
  ];

  meta = {
    description = "Modern shell";
    homepage = "https://github.com/geophile/marcel";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kud ];
    mainProgram = "marcel";
  };
})
