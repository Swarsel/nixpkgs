{
  lib,
  fetchFromGitHub,
  chromaprint,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "audiomatch";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "unmade";
    repo = "audiomatch";
    tag = version;
    hash = "sha256-I7gTP2lwg4EDNmI+tVmI721/nEDShb7q21tD9tRbskY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
     --replace-fail 'poetry>=0.12,<1.0' "poetry-core" \
     --replace-fail 'poetry.masonry.api' 'poetry.core.masonry.api'

    substituteInPlace src/audiomatch/fingerprints.py \
     --replace-fail 'fpcalc' '${lib.getExe chromaprint}'
  '';

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  build-system = [
    python3Packages.poetry-core
    python3Packages.distutils
  ];

  pyproject = true;

  meta = {
    description = "A small command-line tool to find similar audio files";
    homepage = "https://github.com/unmade/audiomatch";
    changelog = "https://github.com/unmade/audiomatch/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ leha44581 ];
    platforms = lib.platforms.all;
    mainProgram = "audiomatch";
  };
}
