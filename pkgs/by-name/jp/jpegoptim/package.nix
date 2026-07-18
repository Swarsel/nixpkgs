{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jpegoptim";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "tjko";
    repo = "jpegoptim";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Nw9mz5zefkRwqkTIyBQyDlANHEx4dztiIiTuXUnuCKM=";
  };

  buildInputs = [ libjpeg ];
  # There are no checks, it seems.
  doCheck = false;

  meta = {
    description = "Optimize JPEG files";
    homepage = "https://www.kokkonen.net/tjko/projects.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "jpegoptim";
  };
})
