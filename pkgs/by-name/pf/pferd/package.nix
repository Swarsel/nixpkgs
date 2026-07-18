{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pferd";
  version = "3.9.2";

  src = fetchFromGitHub {
    owner = "Garmelon";
    repo = "PFERD";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-q1IyuANj47M3KR8qQXASf3WOpFgjNGD/gFZn1l6grTk=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    aiohttp
    beautifulsoup4
    rich
    keyring
    certifi
  ];

  pyproject = true;

  meta = {
    description = "Tool for downloading course-related files from ILIAS";
    homepage = "https://github.com/Garmelon/PFERD";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pferd";
  };
})
