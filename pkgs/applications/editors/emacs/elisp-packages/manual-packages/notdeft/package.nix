{
  lib,
  stdenv,
  fetchFromGitHub,
  hydra,
  ivy,
  melpaBuild,
  pkg-config,
  tclap,
  unstableGitUpdater,
  xapian,
  # Configurable options
  # Include pre-configured hydras
  withHydra ? false,
  # Include Ivy integration
  withIvy ? false,
}:

melpaBuild {
  pname = "notdeft";
  version = "0-unstable-2025-02-04";

  src = fetchFromGitHub {
    owner = "hasu";
    repo = "notdeft";
    rev = "de2b6a7666e9e5010184966f89a04241f221afe3";
    hash = "sha256-B8aVRb8hyAKmHTTVCtDRcb2F0Rs5zhlqyfRe7IxH5jc=";
  };

  postPatch = ''
    substituteInPlace notdeft-xapian.el \
      --replace-fail 'defcustom notdeft-xapian-program nil' \
                     "defcustom notdeft-xapian-program \"$out/bin/notdeft-xapian\""
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    tclap
    xapian
  ];

  preBuild = ''
    $CXX -std=c++11 -o notdeft-xapian xapian/notdeft-xapian.cc -lxapian
  '';

  preInstall = ''
    install -D --target-directory=$out/bin notdeft-xapian
  '';

  files = ''
    (:defaults
     ${lib.optionalString withHydra ''"extras/notdeft-global-hydra.el"''}
     ${lib.optionalString withHydra ''"extras/notdeft-mode-hydra.el"''}
     ${lib.optionalString withIvy ''"extras/notdeft-ivy.el"''})
  '';

  packageRequires = lib.optional withHydra hydra ++ lib.optional withIvy ivy;

  passthru = {
    updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
  };

  meta = {
    description = "Fork of Deft that uses Xapian as a search engine";
    homepage = "https://tero.hasu.is/notdeft/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.nessdoor ];
    platforms = lib.platforms.linux;
  };
}
