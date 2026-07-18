{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  glib,
  gobject-introspection,
  libgee,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gxml";
  version = "0.20.4";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gxml";
    rev = finalAttrs.version;
    hash = "sha256-/gaWuUytBsvAsC95ee6MtTW6g3ltGbkD+JWqrAjJLDc=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    # https://gitlab.gnome.org/GNOME/gxml/-/merge_requests/24
    # https://gitlab.gnome.org/GNOME/gxml/-/merge_requests/28
    substituteInPlace gxml/gxml.pc.in \
      --replace-fail "includedir=@prefix@/include" "includedir=${placeholder "dev"}/include" \
      --replace-fail ">=2" ">= 2" \
      --replace-fail ">=0" ">= 0"
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
  ];

  propagatedBuildInputs = [
    glib
    libgee
    libxml2
  ];

  # https://github.com/NixOS/nixpkgs/issues/407969
  doCheck = false;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Provides a GObject API for manipulating XML and a Serializable framework from GObject to XML";
    homepage = "https://gitlab.gnome.org/GNOME/gxml";
    changelog = "https://gitlab.gnome.org/GNOME/gxml/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ jmarmstrong1207 ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
