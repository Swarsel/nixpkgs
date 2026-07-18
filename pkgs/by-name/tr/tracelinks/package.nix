{
  lib,
  stdenv,
  fetchFromGitHub,
  help2man,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tracelinks";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "flox";
    repo = "tracelinks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sGC1TdcugitMgafnCZGpwYPqWioX+fRl2ZqDZE9levY=";
  };

  nativeBuildInputs = [ help2man ];

  makeFlags = [
    "PREFIX=$(out)"
    "VERSION=${finalAttrs.version}"
  ];

  doCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Report on symbolic links encountered in path traversals";
    homepage = "https://github.com/flox/tracelinks";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ limeytexan ];
    platforms = lib.platforms.unix;
  };
})
