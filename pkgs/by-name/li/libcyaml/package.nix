{
  lib,
  stdenv,
  fetchFromGitHub,
  libyaml,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcyaml";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "tlsa";
    repo = "libcyaml";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JIN/cvh9PRl4/K0Z3WZtSCA3casBxyaxNxjXZZdQRWQ=";
  };

  buildInputs = [ libyaml ];

  makeFlags = [
    "VARIANT=release"
    "PREFIX=$(out)"
  ];

  meta = {
    description = "C library for reading and writing YAML";
    homepage = "https://github.com/tlsa/libcyaml";
    changelog = "https://github.com/tlsa/libcyaml/raw/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    platforms = lib.platforms.unix;
  };
})
