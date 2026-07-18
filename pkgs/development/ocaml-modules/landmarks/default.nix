{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "landmarks";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "LexiFi";
    repo = "landmarks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9o9jf0M3zKc+Xojs4dqPRctYswSYqIo0jeOvkfdLfZ4=";
  };

  doCheck = true;

  meta = {
    description = "Simple Profiling Library for OCaml";

    longDescription = ''
      Landmarks is a simple profiling library for OCaml. It provides
      primitives to measure time spent in portion of instrumented code. The
      instrumentation of the code may either done by hand, automatically or
      semi-automatically using the ppx pepreprocessor (see landmarks-ppx package).
    '';

    homepage = "https://github.com/LexiFi/landmarks";
    changelog = "https://raw.githubusercontent.com/LexiFi/landmarks/refs/tags/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kenran ];
  };
})
