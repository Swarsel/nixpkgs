{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  libsepol,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (libsepol) se_url;
  pname = "checkpolicy";
  version = "3.11";

  src = fetchurl {
    url = "${finalAttrs.se_url}/${finalAttrs.version}/checkpolicy-${finalAttrs.version}.tar.gz";
    hash = "sha256-m4G/zu9/qdAvmHLlanhvND3FjvS1cT3ODVxBbluEzvo=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [ libsepol ];

  makeFlags = [
    "PREFIX=$(out)"
    "LIBSEPOLA=${lib.getLib libsepol}/lib/libsepol.a"
  ];

  meta =
    removeAttrs libsepol.meta [
      "outputsToInstall"
      "name"
    ]
    // {
      description = "SELinux policy compiler";
      mainProgram = "checkpolicy";
    };
})
