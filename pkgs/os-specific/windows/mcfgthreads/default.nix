{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  writeScriptBin,
}:
let
  dllTool = writeScriptBin "dlltool" ''
    ${stdenv.cc.targetPrefix}dlltool "$@"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mcfgthread";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "lhmouse";
    repo = "mcfgthread";
    tag = "v${lib.versions.majorMinor finalAttrs.version}-ga.${lib.versions.patch finalAttrs.version}";
    hash = "sha256-KjZqFaTbPhdI87j11ugSu6Yoe+Rf473+AwopaIfNrKY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    sed -z "s/Rules for tests.*//;s/'cpp'/'c'/g" -i meson.build
  '';

  nativeBuildInputs = [
    dllTool
    meson
    ninja
  ];

  meta = {
    description = "Threading support library for Windows 7 and above";
    homepage = "https://github.com/lhmouse/mcfgthread/wiki";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.windows;
    teams = [ lib.teams.windows ];
  };
})
