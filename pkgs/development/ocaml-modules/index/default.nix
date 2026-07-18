{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  cmdliner,
  crowbar,
  fetchpatch,
  fmt,
  logs,
  lru,
  mtime,
  optint,
  ppx_repr,
  progress,
  re,
  repr,
  semaphore-compat,
  stdlib-shims,
}:

buildDunePackage (finalAttrs: {
  pname = "index";
  version = "1.6.2";

  src = fetchurl {
    url = "https://github.com/mirage/index/releases/download/${finalAttrs.version}/index-${finalAttrs.version}.tbz";
    hash = "sha256-k4iDUJik7UTuztBw7YaFXASd8SqYMR1JgLm3JOyriGA=";
  };

  patches = [
    # Compatibility with cmdliner 2.0
    (fetchpatch {
      hash = "sha256-Vc4r/I3TeIy/D4FcYzj4vRrH87vI2JRagqAXhD9BUxc=";
      includes = [ "*.ml" ];
      url = "https://github.com/mirage/index/commit/aa7aa4734213f74a246f66719a1085b522f431d4.patch";
    })
  ];

  # Compatibility with logs 0.8.0
  postPatch = ''
    substituteInPlace test/unix/dune --replace-warn logs.fmt 'logs.fmt logs.threaded'
  '';

  buildInputs = [
    stdlib-shims
  ];

  propagatedBuildInputs = [
    cmdliner
    fmt
    logs
    mtime
    ppx_repr
    progress
    repr
    semaphore-compat
    optint
    lru
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
    re
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Platform-agnostic multi-level index";
    homepage = "https://github.com/mirage/index";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
