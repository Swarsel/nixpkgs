{
  lib,
  stdenv,
  autoreconfHook,
  bash,
  fetchFromCodeberg,
  libhx,
  nix-update-script,
  perl,
  perlPackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hxtools";
  version = "20251011";

  src = fetchFromCodeberg {
    owner = "jengelh";
    repo = "hxtools";
    tag = "rel-${finalAttrs.version}";
    hash = "sha256-qwo8QfC1ZEvMTU7g2ZnIX3WQM+xjSPb6Y/inPI20x/g=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    # Perl and Bash are pulled to make patchShebangs work.
    perl
    bash
    libhx
  ]
  ++ (with perlPackages; [ TextCSV_XS ]);

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Collection of small tools over the years by j.eng";
    homepage = "https://inai.de/projects/hxtools/";

    # Taken from https://codeberg.org/jengelh/hxtools/src/branch/master/LICENSES.txt
    license = with lib.licenses; [
      mit
      bsd2Patent
      lgpl21Plus
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      meator
      chillcicada
    ];

    platforms = lib.platforms.all;
  };
})
