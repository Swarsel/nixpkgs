{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fixDarwinDylibNames,
  qtbase,
  zlib,
  qt5compat ? null,
}:

stdenv.mkDerivation rec {
  pname = "quazip";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "stachenov";
    repo = "quazip";
    rev = "v${version}";
    sha256 = "sha256-AOamvy2UgN8n7EZ8EidWkVzRICzEXMmvZsB18UwxIVo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ] ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    zlib
    qtbase
  ];

  propagatedBuildInputs = [ qt5compat ];
  dontWrapQtApps = true;

  meta = {
    description = "Provides access to ZIP archives from Qt programs";
    homepage = "https://stachenov.github.io/quazip/"; # Migrated from http://quazip.sourceforge.net/
    license = lib.licenses.lgpl21Plus;
    platforms = with lib.platforms; linux ++ darwin;
  };
}
