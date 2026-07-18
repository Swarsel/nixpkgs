{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  fetchpatch2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysrt";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "byroot";
    repo = "pysrt";
    rev = "v${version}";
    sha256 = "1f5hxyzlh5mdvvi52qapys9qcinffr6ghgivb6k4jxa92cbs3mfg";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-nikMPwj3OHvl6LunAfRk6ZbFUvVgPwF696Dt8R7BY4U=";
      url = "https://github.com/byroot/pysrt/commit/93f52f6d4f70f4e18dc71deeaae0ec1e9100a50f.patch?full_index=1";
    })
  ];

  propagatedBuildInputs = [ chardet ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python library used to edit or create SubRip files";
    homepage = "https://github.com/byroot/pysrt";
    license = lib.licenses.gpl3Only;
    mainProgram = "srt";
  };
}
