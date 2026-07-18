{
  lib,
  stdenv,
  fetchurl,
  libxcb,
  pkg-config,
  testers,
  writeScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxcb-util";
  version = "0.4.1";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/xcb-util-${finalAttrs.version}.tar.xz";
    hash = "sha256-Wr47u9jlTw+j7JRSkbfo+oz9PMzENxj4dYQw+UEm5RI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libxcb ];
  propagatedBuildInputs = [ libxcb ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname xcb-util \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "XCB utility libraries";

    longDescription = ''
      The XCB util modules provides a number of libraries which sit on top of libxcb, the core
      X protocol library, and some of the extension libraries. These experimental libraries provid
      convenience functions and interfaces which make the raw X protocol more usable. Some of the
      libraries also provide client-side code which is not strictly part of the X protocol but which
      have traditionally been provided by Xlib.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcb-util";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "xcb-atom"
      "xcb-aux"
      "xcb-event"
      "xcb-util"
    ];
  };
})
