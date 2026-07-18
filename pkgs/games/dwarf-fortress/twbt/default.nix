{
  lib,
  fetchurl,
  dfVersion,
  stdenvNoCC,
  unzip,
}:

let
  inherit (lib)
    getAttr
    hasAttr
    licenses
    maintainers
    platforms
    ;

  twbt-releases = {
    "0.44.12" = {
      hash = "sha256-cKomZmTLHab9K8k0pZsB2uMf3D5/SVhy2GRusLdp7oE=";
      prerelease = false;
      twbtRelease = "6.54";
    };

    "0.47.05" = {
      dfhackRelease = "0.47.05-r8";
      hash = "sha256-qiNs6iMAUNGiq0kpXqEs4u4Wcrjf6/qA/dzBe947Trc=";
      prerelease = false;
      twbtRelease = "6.xx";
    };
  };

  release =
    if hasAttr dfVersion twbt-releases then
      getAttr dfVersion twbt-releases
    else
      throw "[TWBT] Unsupported Dwarf Fortress version: ${dfVersion}";
in

stdenvNoCC.mkDerivation rec {
  pname = "twbt";
  version = release.twbtRelease;

  src = fetchurl {
    inherit (release) hash;

    url =
      if version == "6.xx" then
        "https://github.com/thurin/df-twbt/releases/download/${release.dfhackRelease}/twbt-${version}-linux64-${release.dfhackRelease}.zip"
      else
        "https://github.com/mifki/df-twbt/releases/download/v${version}/twbt-${version}-linux.zip";
  };

  outputs = [
    "lib"
    "art"
    "out"
  ];

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $lib/hack/{plugins,lua} $art/data/art
    cp -a */twbt.plug.so $lib/hack/plugins/
    cp -a *.lua $lib/hack/lua/
    cp -a *.png $art/data/art/
  '';

  sourceRoot = ".";

  passthru = {
    inherit dfVersion;
  };

  meta = {
    description = "Plugin for Dwarf Fortress / DFHack that improves various aspects of the game interface";
    homepage = "https://github.com/mifki/df-twbt";
    license = licenses.mit;

    maintainers = with maintainers; [
      Baughn
      numinit
    ];

    platforms = platforms.linux;
  };
}
