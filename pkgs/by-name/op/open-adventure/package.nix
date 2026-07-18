{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  coreutils,
  cppcheck,
  libedit,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "open-adventure";
  version = "1.20";

  src = fetchFromGitLab {
    owner = "esr";
    repo = "open-adventure";
    tag = finalAttrs.version;
    hash = "sha256-xbsMz99CNLhpM6BSJVcRzxPB6tUYfPy/3Z+8BKt8b1E=";
  };

  postPatch = ''
    patchShebangs --build make_dungeon.py

    # https://gitlab.com/esr/open-adventure/-/issues/70
    substituteInPlace Makefile --replace-fail "--template " "--template="

    substituteInPlace tests/tapview --replace-fail "/bin/echo" ${lib.getExe' coreutils "echo"}
  '';

  nativeBuildInputs = [
    python3Packages.python
    pkg-config
    asciidoctor
  ];

  buildInputs = [
    python3Packages.pyyaml
    libedit
  ];

  buildFlags = [
    "advent.6"
  ];

  doCheck = true;

  nativeCheckInputs = [
    python3Packages.pylint
    cppcheck
  ];

  installPhase = ''
    runHook preInstall

    mkdir -vp "$out/bin" "$out/share/man/man6" "$out/share/applications/" "$out/share/icons/hicolor/scalable/apps"
    install -m 555 ./advent $out/bin
    install -m 444 ./advent.6 $out/share/man/man6
    install -m 444 ./advent.desktop $out/share/applications
    install -m 444 ./advent.svg $out/share/icons/hicolor/scalable/apps

    runHook postInstall
  '';

  meta = {
    description = "Forward-port of the Crowther/Woods Adventure 2.5 game from 1995";

    longDescription = ''
      This code is a forward-port of the Crowther/Woods Adventure 2.5 game
      from 1995, last version in the main line of Colossal Cave Adventure
      development written by Crowther and Woods. The authors have given
      permission and encouragement to this release.
    '';

    homepage = "http://www.catb.org/~esr/open-adventure/";
    changelog = "https://gitlab.com/esr/open-adventure/-/blob/${finalAttrs.version}/NEWS.adoc";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ EmanuelM153 ];
    platforms = lib.platforms.all;
    mainProgram = "advent";
  };
})
