{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "filebytes";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "sashs";
    repo = "filebytes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8DGVCqWnEiqLCKWAYWrAjr50ZB6SMPMH+VqMqpALnVo=";
  };

  patches = [
    # Upstream PR: https://github.com/sashs/filebytes/pull/36
    (fetchpatch {
      hash = "sha256-VizYOqyJ3xpJIU4KKsYcz2DCurlfrWTgdsn84FVWD6w=";
      name = "python-3.14.patch";
      url = "https://github.com/sashs/filebytes/commit/469058d50d4b7ff8da54b623a0a1aa972cd78dc6.patch";
    })
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Scripts to parse ELF, PE, Mach-O and OAT (Android Runtime)";
    homepage = "https://scoding.de/filebytes-introduction";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bennofs ];
  };
})
