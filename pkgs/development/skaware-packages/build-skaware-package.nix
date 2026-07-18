{
  lib,
  stdenv,
  fetchurl,
  cleanPackaging,
  nix-update-script,
}:
{
  # TODO(Profpatsch): automatically infer most of these
  # : list string
  configureFlags,
  # : string
  description,
  # : string
  pname,
  # mostly for moving and deleting files from the build directory
  # : lines
  postInstall,
  # : string
  version,
  # : attributes to be merged into meta
  broken ? false,
  # : list Maintainer
  maintainers ? [ ],
  # : drv | null
  manpages ? null,
  # : list string
  outputs ? [
    "bin"
    "lib"
    "dev"
    "doc"
    "out"
  ],
  # : passthru arguments (e.g. tests)
  passthru ? { },
  # : list Platform
  platforms ? lib.platforms.all,
  # : string
  postConfigure ? null,
  # : string
  sha256 ? lib.fakeSha256,
}:

let

  # File globs that can always be deleted
  commonNoiseFiles = [
    ".gitignore"
    "Makefile"
    "INSTALL"
    "configure"
    "patch-for-solaris"
    "src/**/*"
    "tools/**/*"
    "package/**/*"
    "config.mak"
  ];

  # File globs that should be moved to $doc
  commonMetaFiles = [
    "COPYING"
    "AUTHORS"
    "NEWS"
    "CHANGELOG"
    "README"
    "README.*"
    "DCO"
    "CONTRIBUTING"
  ];

in
stdenv.mkDerivation {
  inherit pname version;
  inherit postConfigure;

  src = fetchurl {
    inherit sha256;
    url = "https://skarnet.org/software/${pname}/${pname}-${version}.tar.gz";
  };

  outputs =
    if manpages == null then
      outputs
    else
      assert (
        lib.assertMsg (!lib.elem "man" outputs)
          "If you pass `manpages` to `skawarePackages.buildPackage`, you cannot have a `man` output already!"
      );
      # insert as early as possible, but keep the first element
      if lib.length outputs > 0 then
        [
          (lib.head outputs)
          "man"
        ]
        ++ lib.tail outputs
      else
        [ "man" ];

  configureFlags =
    configureFlags
    ++ [
      "--enable-absolute-paths"
      # We assume every nix-based cross target has urandom.
      # This might not hold for e.g. BSD.
      "--with-sysdep-devurandom=yes"
      (if stdenv.hostPlatform.isDarwin then "--disable-shared" else "--enable-shared")
    ]
    # On darwin, the target triplet from -dumpmachine includes version number,
    # but skarnet.org software uses the triplet to test binary compatibility.
    # Explicitly setting target ensures code can be compiled against a skalibs
    # binary built on a different version of darwin.
    # http://www.skarnet.org/cgi-bin/archive.cgi?1:mss:623:heiodchokfjdkonfhdph
    ++ (lib.optional stdenv.hostPlatform.isDarwin "--build=${stdenv.hostPlatform.system}");

  makeFlags = lib.optionals stdenv.cc.isClang [
    "AR=${stdenv.cc.targetPrefix}ar"
    "RANLIB=${stdenv.cc.targetPrefix}ranlib"
  ];

  # TODO(Profpatsch): ensure that there is always a $doc output!
  postInstall = ''
    echo "Cleaning & moving common files"
    ${
      cleanPackaging.commonFileActions {
        docFiles = commonMetaFiles;
        noiseFiles = commonNoiseFiles;
      }
    } $doc/share/doc/${pname}

    ${
      if manpages == null then
        ''echo "no manpages for this package"''
      else
        ''
          echo "copying manpages"
          cp -vr ${manpages} $man
        ''
    }

    ${postInstall}
  '';

  postFixup = ''
    ${cleanPackaging.checkForRemainingFiles}
  '';

  dontDisableStatic = true;
  enableParallelBuilding = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--url"
        "https://github.com/skarnet/${pname}"
        "--override-filename"
        "pkgs/development/skaware-packages/${pname}/default.nix"
      ];
    };
  }
  // passthru
  // (if manpages == null then { } else { inherit manpages; });

  meta = {
    inherit broken description platforms;
    homepage = "https://skarnet.org/software/${pname}/";
    license = lib.licenses.isc;

    maintainers =
      with lib.maintainers;
      [
        pmahoney
        Profpatsch
        qyliss
      ]
      ++ maintainers;
  };

}
