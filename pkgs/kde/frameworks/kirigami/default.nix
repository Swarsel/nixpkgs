{
  stdenv,
  fetchpatch,
  mkKdeDerivation,
  qqc2-desktop-style,
  qt5compat,
  qtdeclarative,
  qtsvg,
  qttools,
}:
# Kirigami has a runtime dependency on qqc2-desktop-style,
# which has a build time dependency on Kirigami.
# So, build qqc2-desktop-style against unwrapped Kirigami,
# and replace all the other Kirigami with a wrapper that
# propagates both Kirigami and qqc2-desktop-style.
# This is a hack, but what can you do.
let
  unwrapped = mkKdeDerivation {
    pname = "kirigami";

    patches = [
      # upstream PR: https://invent.kde.org/frameworks/kirigami/-/merge_requests/1991
      ./rb-templates.patch
    ];

    extraBuildInputs = [ qtdeclarative ];

    extraNativeBuildInputs = [
      qtsvg
      qttools
    ];

    extraPropagatedBuildInputs = [ qt5compat ];
  };
in
stdenv.mkDerivation {
  inherit (unwrapped) version;
  pname = "kirigami-wrapped";

  propagatedBuildInputs = [
    unwrapped
    qqc2-desktop-style
  ];

  dontUnpack = true;
  dontWrapQtApps = true;

  passthru = {
    inherit unwrapped;
  };
}
