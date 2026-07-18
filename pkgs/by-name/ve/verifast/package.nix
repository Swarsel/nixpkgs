{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  darwin,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gnome2,
  gtk2,
  libxml2,
  pango,
}:

let

  # Linux only
  libPath =
    lib.makeLibraryPath [
      stdenv.cc.libc
      stdenv.cc.cc
      gtk2
      gdk-pixbuf
      atk
      pango
      glib
      cairo
      freetype
      fontconfig
      libxml2
      gnome2.gtksourceview
    ]
    + ":${lib.getLib stdenv.cc.cc}/lib64:$out/libexec";

  patchExe = x: ''
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${libPath} ${x}
  '';

  patchLib = x: ''
    patchelf --set-rpath ${libPath} ${x}
  '';

  pname = "verifast";
  version = "25.08";

in
stdenv.mkDerivation (
  finalAttrs:
  let
    srcs = {
      aarch64-darwin = fetchurl {
        hash = "sha256-/UicTlA4lFRk3OBgcsiS8YtDGmb7R7d6zeVLZo49HV8=";
        url = "https://github.com/verifast/verifast/releases/download/${finalAttrs.version}/${pname}-${finalAttrs.version}-macos-aarch.tar.gz";
      };

      x86_64-linux = fetchurl {
        hash = "sha256-HkABnWrdkb9yFByG9AB/L+Hu9n9FPLf7jx9at9MdUJ8=";
        url = "https://github.com/verifast/verifast/releases/download/${finalAttrs.version}/${pname}-${finalAttrs.version}-linux.tar.gz";
      };
    };
  in
  {
    inherit pname version;

    src =
      srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

    nativeBuildInputs = lib.optional stdenv.hostPlatform.isDarwin darwin.sigtool;

    installPhase = ''
      mkdir -p $out/bin
      cp -R bin $out/libexec
    ''
    + (lib.optionalString stdenv.hostPlatform.isLinux ''
      ${patchExe "$out/libexec/verifast"}
      ${patchExe "$out/libexec/vfide"}
      ${patchLib "$out/libexec/libz3.so"}
    '')
    + (lib.optionalString stdenv.hostPlatform.isDarwin ''
      cp -R lib $out/lib
      install_name_tool -change '@executable_path/../lib/libz3.dylib' $out/lib/libz3.dylib $out/libexec/verifast

      install_name_tool -change libz3.dylib $out/lib/libz3.dylib $out/libexec/vfide-core
      ln -s $out/libexec/vfide-core $out/bin/vfide-core

      for f in $out/libexec/vfide-core $out/lib/*.dylib; do
          for old in `otool -L $f | fgrep homebrew | sed -E 's|^[[:space:]]+([^ ]+).*$|\1|g'`; do
              new=`echo $old | sed -E 's|/opt/homebrew/.+/lib/([^ ]+)|\1|'`
              install_name_tool -change $old $out/lib/$new $f
              codesign --force -s - $f
          done
      done
      # include path points to $out/bin
      ln -s $out/libexec/*.{h,gh,cfmanifest,c} $out/bin/
    '')
    + ''
      ln -s $out/libexec/verifast $out/bin/verifast
      ln -s $out/libexec/vfide    $out/bin/vfide
    '';

    dontConfigure = true;
    dontStrip = true;

    meta = {
      description = "Verification for C and Java programs via separation logic";
      homepage = "https://people.cs.kuleuven.be/~bart.jacobs/verifast/";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = [ lib.maintainers.thoughtpolice ];
      platforms = builtins.attrNames srcs;
    };
  }
)
