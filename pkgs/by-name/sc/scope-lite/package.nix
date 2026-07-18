{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scope-lite";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "scope-lite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EZ+bBnMPpgATANa+al5SnVEfUFYc0TkaPTLNHD6zcWU=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Migration path to C++ library extensions scope_exit, scope_fail, scope_success, unique_resource";
    homepage = "https://github.com/martinmoene/scope-lite";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.shlevy ];
    platforms = lib.platforms.all;
  };
})
