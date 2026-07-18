{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxv,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxvmc";
  version = "1.0.15";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXvMC-${finalAttrs.version}.tar.xz";
    hash = "sha256-T1GK/ePX/UNTRq97No0vc1F/PV+CZHyWLK8/e7j/cHg=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    libx11
    libxext
    libxv
  ];

  propagatedBuildInputs = [ xorgproto ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXvMC \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X-Video Motion Compensation API";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxvmc";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "xvmc"
      "xvmc-wrapper"
    ];
  };
})
