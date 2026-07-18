{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  json-glib,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vala-lint";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vala-lang";
    repo = "vala-lint";
    rev = finalAttrs.version;
    hash = "sha256-63T+wLdnGtVBxKkkkj7gJx0ebApam922Z+cmk2R7Ys0=";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    glib
    json-glib
  ];

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Check Vala code files for code-style errors";

    longDescription = ''
      Small command line tool and library for checking Vala code files for code-style errors.
      Based on the elementary Code-Style guidelines.
    '';

    homepage = "https://github.com/vala-lang/vala-lint";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.vala-lint";
    teams = [ lib.teams.pantheon ];
  };
})
