{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libsForQt5,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qcomicbook";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "stolowski";
    repo = "QComicBook";
    rev = finalAttrs.version;
    sha256 = "1b769lp6gfwds4jb2g7ymhdm9c06zg57zpyz3zpdb40w07zfsjzv";
  };

  patches = [
    # https://github.com/stolowski/QComicBook/pull/45
    (fetchpatch {
      hash = "sha256-q0X2i21JgtBfRfyMGpuUyB9GtIiWiFo6IWME6EBMSwk=";
      name = "cmake-4-compatibility.patch";
      url = "https://github.com/stolowski/QComicBook/commit/424a188f63171842ce8fad86fa85c4e03e405618.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
    libsForQt5.qtx11extras
    libsForQt5.poppler
  ];

  postInstall = ''
    substituteInPlace $out/share/applications/*.desktop \
      --replace "Exec=qcomicbook" "Exec=$out/bin/qcomicbook"
  '';

  meta = {
    description = "Comic book reader in Qt5";

    longDescription = ''
      QComicBook is a viewer for PDF files and comic book archives containing
      jpeg/png/xpm/gif/bmp images, which aims at convenience and simplicity.
      Features include: automatic unpacking of archive files, full-screen mode, continuous
      scrolling mode, double-pages viewing, manga mode, thumbnails view, page scaling,
      mouse or keyboard navigation etc.
    '';

    homepage = "https://github.com/stolowski/QComicBook";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ greydot ];
    platforms = lib.platforms.linux;
    mainProgram = "qcomicbook";
  };
})
