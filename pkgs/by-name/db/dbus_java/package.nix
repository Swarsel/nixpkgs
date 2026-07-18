{
  lib,
  stdenv,
  fetchurl,
  gettext,
  jdk8,
  libmatthew_java,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dbus-java";
  version = "2.7";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-java/dbus-java-${finalAttrs.version}.tar.gz";
    sha256 = "0cyaxd8x6sxmi6pklkkx45j311a6w51fxl4jc5j3inc4cailwh5y";
  };

  buildInputs = [
    gettext
    jdk8
  ];

  env = {
    JAVA = "${jdk8}/bin/java";
    JAVAUNIXJARDIR = "${libmatthew_java}/share/java";
    JAVAUNIXLIBDIR = "${libmatthew_java}/lib/jni";
    JAVA_HOME = jdk8;
    PREFIX = "\${out}";
  };

  # I'm too lazy to build the documentation
  preBuild = ''
    sed -i -e "s|all: bin doc man|all: bin|" \
           -e "s|install: install-bin install-man install-doc|install: install-bin|" Makefile
  '';

  meta = {
    license = lib.licenses.afl21;
    platforms = lib.platforms.linux;
  };
})
