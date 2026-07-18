{
  lib,
  stdenv,
  fetchFromGitHub,
  popt,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "isomd5sum";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "isomd5sum";
    rev = finalAttrs.version;
    sha256 = "sha256-c/4CQtAzatfG1Z3SfyB2OZmfJRMnyrZZTqSApsK7R+Q=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "#/usr/" "#"
    substituteInPlace Makefile --replace "/usr/" "/"
  '';

  strictDeps = true;
  nativeBuildInputs = [ python3 ];
  buildInputs = [ popt ];
  makeFlags = [ "DESTDIR=${placeholder "out"}" ];
  dontConfigure = true;

  # we don't install python stuff as it borks up directories
  installTargets = [
    "install-bin"
    "install-devel"
  ];

  meta = {
    description = "Utilities for working with md5sum implanted in ISO images";
    homepage = "https://github.com/rhinstaller/isomd5sum";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
