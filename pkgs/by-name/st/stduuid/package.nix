{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:
let
  version = "1.2.3";
in
stdenv.mkDerivation {
  inherit version;
  pname = "stduuid";

  src = fetchFromGitHub {
    owner = "mariusbancila";
    repo = "stduuid";
    rev = "v${version}";
    hash = "sha256-MhpKv+gH3QxiaQMx5ImiQjDGrbKUFaaoBLj5Voh78vg=";
  };

  patches = [
    # stduuid report version 1.0 instead of 1.2.3 for cmake's find_package to properly work
    # If version is updated one day, this patch will need to be updated
    (fetchpatch {
      hash = "sha256-tv4rllhngdgjXX35kcM69yXo0DXF/BQ+AUbiC1gJIU8=";
      url = "https://github.com/OlivierLDff/stduuid/commit/b02c70c0a4bef2c82152503e13c9a67d6631b13d.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "C++17 cross-platform implementation for UUIDs";
    homepage = "https://github.com/mariusbancila/stduuid";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.shlevy ];
    platforms = lib.platforms.all;
  };
}
