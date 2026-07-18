{
  lib,
  fetchFromGitHub,
  python3Packages,
  unhide,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "unhide-gui";
  version = "20240510";

  src = fetchFromGitHub {
    owner = "YJesus";
    repo = "Unhide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CcS/rR/jPgbcF09aM4l6z52kwFhdQI1VZOyDF2/X6Us=";
  };

  postPatch = ''
    substituteInPlace unhideGui.py \
      --replace-fail "\This" "This" \
      --replace-fail "__credits__" "#__credits__" \
      --replace-fail "./unhide-linux" "${unhide}/bin/unhide-linux" \
      --replace-fail "./unhide-tcp" "${unhide}/bin/unhide-tcp"
  '';

  buildInputs = [ unhide ];
  propagatedBuildInputs = with python3Packages; [ tkinter ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/unhideGui}
    cp -R *.py $out/share/unhideGui

    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    makeWrapper "${python3Packages.python.interpreter}" "$out/bin/unhideGui" \
      --set PYTHONPATH "$PYTHONPATH" \
      --add-flags "$out/share/unhideGui/unhideGui.py"

    runHook postFixup
  '';

  pyproject = false;

  meta = {
    description = "Forensic tool to find hidden processes and TCP/UDP ports by rootkits, LKMs or other hiding technique";
    homepage = "https://github.com/YJesus/Unhide";
    changelog = "https://github.com/YJesus/Unhide/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tochiaha ];
    platforms = lib.platforms.all;
    mainProgram = "unhide-gui";
  };
})
