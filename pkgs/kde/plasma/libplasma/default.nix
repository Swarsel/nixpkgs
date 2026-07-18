{
  mkKdeDerivation,
  pkg-config,
  qtsvg,
  qtwayland,
  wayland,
}:
mkKdeDerivation {
  pname = "libplasma";

  patches = [
    # https://invent.kde.org/plasma/libplasma/-/merge_requests/1406
    ./rb-extracomponents.patch
  ];

  extraBuildInputs = [
    qtsvg
    qtwayland
    wayland
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
