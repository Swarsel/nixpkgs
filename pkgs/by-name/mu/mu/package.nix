{
  lib,
  stdenv,
  fetchFromGitHub,
  cld2,
  cli11,
  emacs,
  fmt_11,
  glib,
  glibcLocales,
  gmime3,
  meson,
  ninja,
  pkg-config,
  python3,
  texinfo,
  xapian,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mu";
  version = "1.14.2";

  src = fetchFromGitHub {
    owner = "djcb";
    repo = "mu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0svY7XhhimIgsYUbHcNT4OCmpmhE4otRxqoasABEIA4=";
  };

  outputs = [
    "out"
    "mu4e"
  ];

  postPatch = ''
    patchShebangs build-aux/date.py
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    python3
    glibcLocales
  ];

  buildInputs = [
    cld2
    cli11
    emacs
    fmt_11
    glib
    gmime3
    texinfo
    xapian
  ];

  mesonFlags = [
    (lib.strings.mesonEnable "guile" false)
    (lib.strings.mesonEnable "scm" false)
    (lib.strings.mesonEnable "readline" false)
    (lib.strings.mesonEnable "tests" finalAttrs.doCheck)
    (lib.strings.mesonOption "lispdir" "${placeholder "mu4e"}/share/emacs/site-lisp")
  ];

  # Tests need a UTF-8 aware locale configured
  env.LANG = "C.UTF-8";
  doCheck = true;

  postInstall = ''
    rm --verbose $mu4e/share/emacs/site-lisp/mu4e/*.elc
  '';

  # move only the mu4e info manual
  # this has to be after preFixup otherwise the info manual may be moved back by _multioutDocs()
  # we manually move the mu4e info manual instead of setting
  # outputInfo to mu4e because we do not want to move the mu-guile
  # info manual (if it exists)
  postFixup = ''
    moveToOutput share/info/mu4e.info.gz $mu4e
    install-info $mu4e/share/info/mu4e.info.gz $mu4e/share/info/dir
    if [[ -a ''${!outputInfo}/share/info/mu-guile.info.gz ]]; then
      install-info --delete $mu4e/share/info/mu4e.info.gz ''${!outputInfo}/share/info/dir
    else
      rm --verbose --recursive ''${!outputInfo}/share/info
    fi
  '';

  meta = {
    description = "Collection of utilities for indexing and searching Maildirs";
    homepage = "https://www.djcbsoftware.nl/code/mu/";
    changelog = "https://github.com/djcb/mu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      antono
      chvp
      peterhoeg
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mu";
  };
})
