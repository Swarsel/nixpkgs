{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  # tests
  hypothesis,
  pytestCheckHook,
  # docs
  python,
  # build-system
  setuptools,
  sphinx,
  sphinx-rtd-theme,
}:

buildPythonPackage rec {
  pname = "mutagen";
  version = "1.47.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cZ+t7wqXjDG0zzyVYmGzxYtpSLMgIweKIRex3gnw/Jk=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # fix compatibility with hypothesis CI profile
    # (remove on next release)
    (fetchpatch {
      hash = "sha256-jfCz8qTGZpnP6ICMB9K/Dgyp9TQeMuDq+V6kPFA3Q44=";
      url = "https://github.com/quodlibet/mutagen/commit/967212631719de1aeccbd6855c5b6d03f271fdfe.patch";
    })
  ];

  nativeBuildInputs = [
    setuptools
    sphinx
    sphinx-rtd-theme
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  postInstall = ''
    ${python.pythonOnBuildForHost.interpreter} setup.py build_sphinx --build-dir=$doc
  '';

  disabledTests = [
    # Hypothesis produces unreliable results: Falsified on the first call but did not on a subsequent one
    "test_test_fileobj_save"
    "test_test_fileobj_load"
    "test_test_fileobj_delete"
    "test_mock_fileobj"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mutagen" ];

  meta = {
    description = "Python module for handling audio metadata";

    longDescription = ''
      Mutagen is a Python module to handle audio metadata. It supports
      ASF, FLAC, MP4, Monkey's Audio, MP3, Musepack, Ogg Opus, Ogg FLAC,
      Ogg Speex, Ogg Theora, Ogg Vorbis, True Audio, WavPack, OptimFROG,
      and AIFF audio files. All versions of ID3v2 are supported, and all
      standard ID3v2.4 frames are parsed. It can read Xing headers to
      accurately calculate the bitrate and length of MP3s. ID3 and APEv2
      tags can be edited regardless of audio format. It can also
      manipulate Ogg streams on an individual packet/page level.
    '';

    homepage = "https://mutagen.readthedocs.io";

    changelog = "https://mutagen.readthedocs.io/en/latest/changelog.html#release-${
      lib.replaceStrings [ "." ] [ "-" ] version
    }";

    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
