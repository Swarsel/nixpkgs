{
  lib,
  buildPythonPackage,
  fetchPypi,
  imutils,
  matplotlib,
  numpy,
  pandas,
  progress,
}:

buildPythonPackage rec {
  pname = "vidstab";
  version = "1.7.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "865c4a097e2a8527aa8bfc96ab0bcc0d280a88cc93eabcc36531268f5d343ce1";
  };

  propagatedBuildInputs = [
    numpy
    pandas
    imutils
    progress
    matplotlib
  ];

  # tests not packaged with pypi
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "vidstab" ];

  meta = {
    description = "Video Stabilization using OpenCV";
    homepage = "https://github.com/AdamSpannbauer/python_video_stab";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
