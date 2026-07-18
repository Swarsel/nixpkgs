{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quill-log";
  version = "12.0.0";

  src = fetchFromGitHub {
    owner = "odygrd";
    repo = "quill";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LtajNT+AN6wOEj3BLU3RctXLSliIvpV/73FJeerUQFk=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Asynchronous Low Latency C++17 Logging Library";
    homepage = "https://github.com/odygrd/quill";
    changelog = "https://github.com/odygrd/quill/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.odygrd ];
    platforms = lib.platforms.all;
    downloadPage = "https://github.com/odygrd/quill";
  };
})
