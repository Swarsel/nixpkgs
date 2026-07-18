{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cairosvg,
  imageio,
  imageio-ffmpeg,
  numpy,
  pwkit,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "drawsvg";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "cduck";
    repo = "drawsvg";
    tag = finalAttrs.version;
    hash = "sha256-JC7u6bEB7RCJVLeYnNqACmddLI5F5PyaaBxaAZ+N/5s=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  optional-dependencies = {
    all = [
      cairosvg
      imageio
      imageio-ffmpeg
      numpy
      pwkit
    ];

    color = [
      numpy
      pwkit
    ];

    raster = [
      cairosvg
      imageio
      imageio-ffmpeg
      numpy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "drawsvg" ];

  meta = {
    description = "Programmatically generate SVG (vector) images, animations, and interactive Jupyter widgets";
    homepage = "https://github.com/cduck/drawsvg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
