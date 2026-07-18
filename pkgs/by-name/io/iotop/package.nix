{
  lib,
  fetchurl,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "iotop";
  version = "0.6";

  src = fetchurl {
    url = "http://guichaz.free.fr/iotop/files/iotop-${finalAttrs.version}.tar.bz2";
    sha256 = "0nzprs6zqax0cwq8h7hnszdl3d2m4c2d4vjfxfxbnjfs9sia5pis";
  };

  patches = [
    (fetchpatch {
      sha256 = "0rdgz6xpmbx77lkr1ixklliy1aavdsjmfdqvzwrjylbv0xh5wc8z";
      url = "https://repo.or.cz/iotop.git/patch/99c8d7cedce81f17b851954d94bfa73787300599";
    })
  ];

  doCheck = false;
  build-system = [ python3Packages.setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "iotop" ];

  meta = {
    description = "Tool to find out the processes doing the most IO";
    homepage = "http://guichaz.free.fr/iotop";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "iotop";
  };
})
