{
  lib,
  fetchFromGitLab,
  fontforge,
  installFonts,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peppercarrot-fonts";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "peppercarrot";
    repo = "fonts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tabiNRJZRwSYGV3DtXhg0C78E7TlDQYcpa/5bJrkhfs=";
    domain = "framagit.org";
  };

  outputs = [
    "out"
    "webfont"
  ];

  postPatch = ''
    # Some fonts are duplicated with symlinks
    find . -type l -delete

    # Already in pkgs.yanone-kaffeesatz
    rm YanoneKaffeesatz*
  '';

  strictDeps = true;

  nativeBuildInputs = [
    fontforge
    installFonts
  ];

  # Those are only built as woff2
  buildPhase = ''
    runHook preBuild
    fontforge -lang=ff -c 'Open("sources/Handserah.sfd"); Generate("Handserah.otf")'
    fontforge -lang=ff -c 'Open("sources/PepperCarrot.sfd"); Generate("PepperCarrot.otf")'
    runHook postBuild
  '';

  __structuredAttrs = true;
  # Other folders include third-party fonts for other alphabets
  sourceRoot = "${finalAttrs.src.name}/Latin";

  meta = {
    description = "Open fonts used in the webcomic Pepper&Carrot";
    homepage = "https://www.peppercarrot.com/en/fonts";
    changelog = "https://framagit.org/peppercarrot/fonts/-/blob/master/CHANGELOG.md";

    license =
      with lib.licenses;
      let
        gpl2font = {
          deprecated = true;
          free = true;
          fullName = "GNU General Public License v2.0 w/Font exception";
          redistributable = true;
          shortName = "gpl2font";
          spdxId = " GPL-2.0-with-font-exception";
          url = "https://spdx.org/licenses/GPL-2.0-with-font-exception.html";
        };
        ofl10 = {
          deprecated = false;
          free = true;
          fullName = "SIL Open Font License 1.0";
          redistributable = true;
          shortName = "ofl10";
          spdxId = "OFL-1.0";
          url = "https://spdx.org/licenses/OFL-1.0.html";
        };
      in
      [
        asl20
        cc-by-30
        gpl2font
        gpl3
        mplus
        ofl
        ofl10
      ];

    maintainers = [ lib.maintainers.nim65s ];
    platforms = lib.platforms.all;
  };
})
