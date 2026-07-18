{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyPkgconfigItems,
  makePkgconfigItem,
  openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "httplib";
  version = "0.30.2";

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-psVyn14QHMXG/x9SOOiR7ZBt8dHqa2A/w92WQQDukKM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    copyPkgconfigItems
  ];

  buildInputs = [ openssl ];

  pkgconfigItems = [
    (makePkgconfigItem rec {
      inherit (finalAttrs) version;
      inherit (finalAttrs.meta) description;
      cflags = [ "-I${variables.includedir}" ];
      name = "httplib";

      variables = rec {
        includedir = "${prefix}/include";
        prefix = placeholder "out";
      };
    })
  ];

  meta = {
    description = "C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";
    changelog = "https://github.com/yhirose/cpp-httplib/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fzakaria
    ];

    platforms = lib.platforms.all;
  };
})
