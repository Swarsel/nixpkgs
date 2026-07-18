{
  lib,
  fetchFromGitHub,
  _7zz,
  python3Packages,
  runCommand,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  # gamma-launcher looks for the "7z", not "7zz"
  _7z = runCommand "7z" { } ''
    mkdir -p $out/bin
    ln -s ${_7zz}/bin/7zz $out/bin/7z
  '';
in
python3Packages.buildPythonApplication rec {
  pname = "gamma-launcher";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "Mord3rca";
    repo = "gamma-launcher";
    tag = "v${version}";
    hash = "sha256-bvlNmpl2L9MAhZMyHwosXrypH1CQrSI1RQwo+sXO7/w=";
  };

  nativeCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  doInstallCheck = true;

  postFixup = ''
    wrapProgram $out/bin/gamma-launcher \
    --prefix PATH : "${
      lib.makeBinPath [
        _7z
      ]
    }"
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    beautifulsoup4
    cloudscraper
    gitpython
    platformdirs
    py7zr
    python-unrar
    requests
    tenacity
    tqdm
  ];

  pyproject = true;
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Python cli to download S.T.A.L.K.E.R. GAMMA";
    homepage = "https://github.com/Mord3rca/gamma-launcher";
    changelog = "https://github.com/Mord3rca/gamma-launcher/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      DrymarchonShaun
      bbigras
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gamma-launcher";
  };
}
