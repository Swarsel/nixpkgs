{
  lib,
  stdenv,
  build-asdf-system,
  pkgs,
  ...
}:

let

  # FIXME: automatically add nativeLibs based on conditions signalled

  overrides = (
    self: super: {
      _3d-math = super._3d-math.overrideLispAttrs (o: {
        flags = o.flags ++ (if o.program == "sbcl" then [ "--dynamic-space-size 4096" ] else [ ]);
      });

      # The antik source archive contains a broken documentation.pdf symlink
      # pointing to documentation/build/latex/Antik.pdf which doesn't exist.
      # All packages built from this archive need the symlink removed.
      antik = super.antik.overrideLispAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          rm -f $out/documentation.pdf
        '';
      });

      antik-base = super.antik-base.overrideLispAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          rm -f $out/documentation.pdf
        '';
      });

      capstone = super.capstone.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.capstone ];
      });

      cffi = super.cffi.overrideLispAttrs (o: {
        javaLibs = [
          (pkgs.fetchMavenArtifact {
            version = "5.9.0";
            artifactId = "jna";
            groupId = "net.java.dev.jna";
            sha256 = "0qbis8acv04fi902qzak1mbagqaxcsv2zyp7b8y4shs5nj0cgz7a";
          })
        ];
      });

      cffi-libffi = super.cffi-libffi.overrideLispAttrs (o: {
        patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./patches/cffi-libffi-darwin-ffi-h.patch ];
        nativeBuildInputs = [ pkgs.libffi ];
        nativeLibs = [ pkgs.libffi ];
      });

      cl-ana_dot_hdf-cffi = super.cl-ana_dot_hdf-cffi.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.hdf5 ];

        env = o.env or { } // {
          NIX_LDFLAGS = toString [ "-lhdf5" ];
        };

        nativeLibs = [ pkgs.hdf5 ];
      });

      cl-async-ssl = super.cl-async-ssl.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.openssl ];
      });

      cl-cairo2 = super.cl-cairo2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.cairo ];
      });

      cl-cairo2-xlib = super.cl-cairo2-xlib.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.gtk2-x11 ];
      });

      cl-cffi-gtk-cairo = super.cl-cffi-gtk-cairo.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.cairo ];
      });

      cl-cffi-gtk-gdk = super.cl-cffi-gtk-gdk.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.gtk3 ];
      });

      cl-cffi-gtk-gdk-pixbuf = super.cl-cffi-gtk-gdk-pixbuf.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.gdk-pixbuf ];
      });

      cl-cffi-gtk-glib = super.cl-cffi-gtk-glib.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.glib ];
      });

      cl-cffi-gtk-pango = super.cl-cffi-gtk-pango.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.pango ];
      });

      cl-charms = super.cl-charms.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.ncurses ];
      });

      cl-freetype2 = super.cl-freetype2.overrideLispAttrs (o: {
        patches = [ ./patches/cl-freetype2-fix-grovel-includes.patch ];
        nativeBuildInputs = [ pkgs.freetype ];
        nativeLibs = [ pkgs.freetype ];
      });

      cl-git = super.cl-git.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libgit2 ];
      });

      cl-glfw = super.cl-glfw.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.glfw ];
      });

      cl-glfw-opengl-core = super.cl-glfw-opengl-core.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libGL ];
      });

      cl-glfw3 = super.cl-glfw3.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.glfw ];
      });

      cl-glu = super.cl-glu.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libGLU ];
      });

      cl-glut = super.cl-glut.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libglut ];
      });

      cl-gobject-introspection = super.cl-gobject-introspection.overrideLispAttrs (o: {
        nativeLibs = [
          pkgs.glib
          pkgs.gobject-introspection
        ];
      });

      cl-gss = super.cl-gss.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libkrb5 ];
      });

      cl-gtk2-gdk = super.cl-gtk2-gdk.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.gtk2-x11 ];
      });

      cl-gtk2-glib = super.cl-gtk2-glib.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.glib ];
      });

      cl-gtk2-pango = super.cl-gtk2-pango.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.pango ];
      });

      cl-liballegro = super.cl-liballegro.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.allegro5 ];
      });

      cl-libuv = super.cl-libuv.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.libuv ];
        nativeLibs = [ pkgs.libuv ];
      });

      cl-libxml2 = super.cl-libxml2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libxml2 ];
      });

      cl-libyaml = super.cl-libyaml.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libyaml ];
      });

      cl-mysql = super.cl-mysql.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.mariadb.client ];
      });

      cl-ode = super.cl-ode.overrideLispAttrs (o: {
        nativeLibs =
          let
            ode' = pkgs.ode.overrideAttrs (o: {
              configureFlags = [
                "--enable-shared"
                "--enable-double-precision"
              ];
            });
          in
          [ ode' ];
      });

      cl-opengl = super.cl-opengl.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libGL ];
      });

      cl-pango = super.cl-pango.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.pango ];
      });

      cl-rabbit = super.cl-rabbit.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.rabbitmq-c ];
        nativeLibs = [ pkgs.rabbitmq-c ];
      });

      cl-rdkafka = super.cl-rdkafka.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.rdkafka ];
        nativeLibs = [ pkgs.rdkafka ];
      });

      cl-readline = super.cl-readline.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.readline ];
      });

      cl-rsvg2 = super.cl-rsvg2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.librsvg ];
      });

      cl-sat_dot_glucose = super.cl-sat_dot_glucose.overrideLispAttrs (o: {
        patches = [ ./patches/cl-sat-binary-from-path.patch ];
        propagatedBuildInputs = [ pkgs.glucose ];
      });

      cl-sat_dot_minisat = super.cl-sat_dot_minisat.overrideLispAttrs (o: {
        propagatedBuildInputs = [ pkgs.minisat ];
      });

      cl-webkit2 = super.cl-webkit2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.webkitgtk_4_1 ];
      });

      cl_plus_ssl = super.cl_plus_ssl.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.openssl ];
      });

      classimp = super.classimp.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.assimp ];
      });

      clsql-postgresql = super.clsql-postgresql.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libpq ];
      });

      clsql-sqlite3 = super.clsql-sqlite3.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.sqlite ];
      });

      consfigurator = super.consfigurator.overrideLispAttrs (o: {
        nativeLibs = [
          pkgs.acl
          pkgs.libcap
        ];
      });

      dbd-mysql = super.dbd-mysql.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.mariadb.client ];
      });

      duckdb = super.duckdb.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.duckdb ];
      });

      foreign-array = super.foreign-array.overrideLispAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          rm -f $out/documentation.pdf
        '';
      });

      gsll = super.gsll.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.gsl ];
        nativeLibs = [ pkgs.gsl ];
      });

      hu_dot_dwim_dot_graphviz = super.hu_dot_dwim_dot_graphviz.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.graphviz ];
      });

      iolib = super.iolib.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.libfixposix ];
        nativeLibs = [ pkgs.libfixposix ];

        systems = [
          "iolib"
          "iolib/os"
          "iolib/pathnames"
        ];
      });

      jpeg-turbo = super.jpeg-turbo.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libjpeg_turbo ];
      });

      keystone = super.keystone.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.keystone ];
      });

      lev = super.lev.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libev ];
      });

      libusb-ffi = super.libusb-ffi.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libusb-compat-0_1 ];
      });

      lispbuilder-sdl-cffi = super.lispbuilder-sdl-cffi.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.SDL ];
      });

      lla = super.lla.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.openblas ];
      });

      magicffi = super.magicffi.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.file ];
      });

      math = super.math.overrideLispAttrs (o: {
        patches = [ ./patches/math-no-compile-time-directory.patch ];
        nativeLibs = [ pkgs.fontconfig ];
      });

      mcclim-fonts = super.mcclim-fonts.overrideLispAttrs (o: {
        lispLibs = o.lispLibs ++ [
          super.cl-dejavu
          super.zpb-ttf
          super.cl-vectors
          super.cl-paths-ttf
          super.flexi-streams
        ];

        systems = [
          "mcclim-fonts"
          "mcclim-fonts/truetype"
        ];
      });

      mcclim-layouts = super.mcclim-layouts.overrideLispAttrs (o: {
        lispLibs = o.lispLibs ++ [
          self.mcclim
        ];

        systems = [
          "mcclim-layouts"
          "mcclim-layouts/tab"
        ];
      });

      mcclim-render = super.mcclim-render.overrideLispAttrs (o: {
        lispLibs = o.lispLibs ++ [
          self.mcclim-fonts
        ];
      });

      md5 = super.md5.overrideLispAttrs (o: {
        lispLibs = [ super.flexi-streams ];
      });

      physical-dimension = super.physical-dimension.overrideLispAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          rm -f $out/documentation.pdf
        '';
      });

      png = super.png.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libpng ];
      });

      pzmq = super.pzmq.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.zeromq ];
        nativeLibs = [ pkgs.zeromq ];
      });

      pzmq-compat = super.pzmq-compat.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.zeromq ];
        nativeLibs = [ pkgs.zeromq ];
      });

      pzmq-examples = super.pzmq-examples.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.zeromq ];
        nativeLibs = [ pkgs.zeromq ];
      });

      pzmq-test = super.pzmq-test.overrideLispAttrs (o: {
        nativeBuildInputs = [ pkgs.zeromq ];
        nativeLibs = [ pkgs.zeromq ];
      });

      science-data = super.science-data.overrideLispAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          rm -f $out/documentation.pdf
        '';
      });

      sdl2 = super.sdl2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.SDL2 ];
      });

      sdl2-image = super.sdl2-image.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.SDL2_image ];
      });

      sdl2-mixer = super.sdl2-mixer.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.SDL2_mixer ];
      });

      sdl2-ttf = super.sdl2-ttf.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.SDL2_ttf ];
      });

      sqlite = super.sqlite.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.sqlite ];
      });

      trivial-package-manager = super.trivial-package-manager.overrideLispAttrs (o: {
        propagatedBuildInputs = [ pkgs.which ];
      });

      trivial-ssh-libssh2 = super.trivial-ssh-libssh2.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libssh2 ];
      });

      vk = super.vk.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.vulkan-loader ];
      });

      vorbisfile-ffi = super.vorbisfile-ffi.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.libvorbis ];
      });

      zmq = super.zmq.overrideLispAttrs (o: {
        nativeLibs = [ pkgs.czmq ];
      });
    }
  );

  qlpkgs = lib.optionalAttrs (builtins.pathExists ./imported.nix) (
    pkgs.callPackage ./imported.nix { inherit build-asdf-system; }
  );

in
qlpkgs.overrideScope overrides
