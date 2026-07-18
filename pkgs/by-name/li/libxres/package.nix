{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxres";
  version = "1.2.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXres-${finalAttrs.version}.tar.xz";
    hash = "sha256-0t6PVAHWyGqJknkWVFR+uN71hd/cDAjMFuJO9q7radw=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    libx11
    libxext
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
      version="$(list-directory-versions --pname libXres \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X-Resource extension client library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxres";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xres" ];
  };
})
