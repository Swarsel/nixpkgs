{
  lib,
  stdenv,
  fetchFromGitHub,
  # build-time deps
  cmake,
  ninja,
  nix-update-script,
  qhull,
  # run-time deps
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgdstk";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heitzmann";
    repo = "gdstk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YDTtjHhc3mXDWj6Tg9ud1h95g2sQ9no1RLd0/cKJxEU=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    zlib
    qhull
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++/Python library for creation and manipulation of GDSII and OASIS files";
    homepage = "https://github.com/heitzmann/gdstk";
    changelog = "https://github.com/heitzmann/gdstk/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.boost;

    maintainers = with lib.maintainers; [
      eljamm
      gonsolo
    ];

    teams = with lib.teams; [ ngi ];
  };
})
