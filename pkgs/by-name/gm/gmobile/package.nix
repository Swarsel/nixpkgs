{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch2,
  glib,
  gobject-introspection,
  gtk-doc,
  json-glib,
  libuev,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  udevCheckHook,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gmobile";
  version = "0.7.1";

  src = fetchFromGitLab {
    owner = "Phosh";
    repo = "gmobile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RXkH+48WzACgNcIROlSTSO4l/ujWVHJDG+Xtk4k7Rdw=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-S3S1FORPC8czFx0ivLVOUhamStaJsKd6oXnh1jbdr3Y=";
      name = "dont-set-libexecdir.patch";
      url = "https://gitlab.gnome.org/World/Phosh/gmobile/-/commit/b085e13898edddf31b6da8c8fc4119bb2cb59c38.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gtk-doc
    meson
    ninja
    pkg-config
    gobject-introspection
    udevCheckHook
    vala
  ];

  buildInputs = [
    glib
    json-glib
    libuev
  ];

  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Functions useful in mobile related, glib based projects";
    homepage = "https://gitlab.gnome.org/World/Phosh/gmobile";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      donovanglover
      armelclo
    ];

    platforms = lib.platforms.linux;
  };
})
