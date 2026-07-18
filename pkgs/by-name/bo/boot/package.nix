{
  lib,
  stdenv,
  fetchurl,
  jdk,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit jdk;
  pname = "boot";
  version = "2.7.2";

  src = fetchurl {
    url = "https://github.com/boot-clj/boot-bin/releases/download/${finalAttrs.version}/boot.sh";
    sha256 = "1hqp3xxmsj5vkym0l3blhlaq9g3w0lhjgmp37g6y3rr741znkk8c";
  };

  propagatedBuildInputs = [ jdk ];
  builder = ./builder.sh;

  meta = {
    description = "Build tooling for Clojure";
    homepage = "https://boot-clj.github.io/";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [ ragge ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "boot";
  };
})
