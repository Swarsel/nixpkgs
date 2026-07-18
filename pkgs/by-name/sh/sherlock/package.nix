{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "sherlock";
  version = "0.16.0-unstable-2026-05-09";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "206068dc7842665130c87e16e1535572d3d1a907";
    hash = "sha256-QM0vHvZ1w9FtM0bGPGvMhhobPKOGQNPacVWB0caoPTw=";
  };

  patches = [
    # Avoid hardcoding sherlock
    ./fix-sherlock-bin-test.patch
  ];

  postPatch = ''
    substituteInPlace tests/sherlock_interactives.py \
      --replace-fail @sherlockBin@ "$out/bin/sherlock"
    substituteInPlace sherlock_project/__init__.py \
      --replace-fail "__version__     = get_version()" "__version__ = \"${finalAttrs.version}\""
  '';

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = with python3.pkgs; [
    rstr
    pytestCheckHook
    jsonschema
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -R ./sherlock_project $out/share

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python3.interpreter} $out/bin/sherlock \
      --add-flags "-m" \
      --add-flags "sherlock_project" \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/share"
  '';

  build-system = with python3.pkgs; [
    poetry-core
  ];

  dependencies = with python3.pkgs; [
    certifi
    colorama
    openpyxl
    pandas
    pysocks
    requests
    requests-futures
    stem
    torrequest
    tomli
  ];

  disabledTestMarks = [
    # tests require internet access
    "online"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "pandas"
  ];

  meta = {
    description = "Hunt down social media accounts by username across social networks";
    homepage = "https://sherlockproject.xyz/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ applePrincess ];
    mainProgram = "sherlock";
  };
})
