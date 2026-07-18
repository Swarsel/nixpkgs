# Builder for Agda packages.

{
  lib,
  stdenv,
  Agda,
  ghcWithPackages,
  makeWrapper,
  nixosTests,
  runCommand,
  self,
  writeText,
}:

let
  inherit (lib)
    attrValues
    elem
    filter
    filterAttrs
    isAttrs
    isList
    platforms
    ;

  inherit (lib.strings)
    concatMapStrings
    concatMapStringsSep
    optionalString
    ;

  mkLibraryFile =
    pkgs:
    let
      pkgs' = if isList pkgs then pkgs else pkgs self;
    in
    writeText "libraries" ''
      ${(concatMapStringsSep "\n" (p: "${p}/${p.libraryFile}") pkgs')}
    '';

  withPackages' =
    {
      pkgs,
      ghc ? ghcWithPackages (p: with p; [ ieee754 ]),
    }:
    let
      libraryFile = mkLibraryFile pkgs;
      pname = "${Agda.meta.mainProgram}WithPackages";
      version = Agda.version;
    in
    runCommand "${pname}-${version}"
      {
        inherit pname version;
        nativeBuildInputs = [ makeWrapper ];

        passthru = {
          inherit
            withPackages
            libraryFile
            ;

          tests = {
            inherit (nixosTests) agda;
            allPackages = withPackages (filter self.lib.isUnbrokenAgdaPackage (attrValues self));
          };

          unwrapped = Agda;
        };

        # Agda is a split package with multiple outputs; do not inherit them here.
        meta = removeAttrs Agda.meta [ "outputsToInstall" ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe Agda} $out/bin/${Agda.meta.mainProgram} \
          ${lib.optionalString (ghc != null) ''--add-flags "--with-compiler=${ghc}/bin/ghc"''} \
          --add-flags "--library-file=${libraryFile}"
        if [ -e ${lib.getExe' Agda "agda-mode"} ]; then
          ln -s ${lib.getExe' Agda "agda-mode"} $out/bin/agda-mode
        fi
      '';

  withPackages = arg: if isAttrs arg then withPackages' arg else withPackages' { pkgs = arg; };

  extensions = [
    "agda"
    "agda-lib"
    "agdai"
    "lagda"
    "lagda.md"
    "lagda.org"
    "lagda.rst"
    "lagda.tex"
    "lagda.typ"
  ];

  defaults =
    {
      meta,
      pname,
      buildInputs ? [ ],
      buildPhase ? null,
      extraExtensions ? [ ],
      installPhase ? null,
      libraryFile ? "${libraryName}.agda-lib",
      libraryName ? pname,
      passthru ? { },
      ...
    }@args:
    let
      agdaWithPkgs = withPackages (filter (p: p ? isAgdaDerivation) buildInputs);
    in
    {
      inherit libraryName libraryFile;
      buildInputs = buildInputs ++ [ agdaWithPkgs ];

      env = args.env or { } // {
        # As documented at https://github.com/NixOS/nixpkgs/issues/172752,
        # we need to set LC_ALL to an UTF-8-supporting locale. However, on
        # darwin, it seems that there is no standard such locale; luckily,
        # the referenced issue doesn't seem to surface on darwin. Hence let's
        # set this only on non-darwin.
        LC_ALL = optionalString (!stdenv.hostPlatform.isDarwin) "C.UTF-8";
      };

      buildPhase =
        if buildPhase != null then
          buildPhase
        else
          ''
            runHook preBuild
            ${lib.getExe agdaWithPkgs} --build-library
            runHook postBuild
          '';

      installPhase =
        if installPhase != null then
          installPhase
        else
          ''
            runHook preInstall
            mkdir -p $out
            find \( ${
              concatMapStringsSep " -or " (p: "-name '*.${p}'") (extensions ++ extraExtensions)
            } \) -exec cp -p --parents -t "$out" {} +
            runHook postInstall
          '';

      isAgdaDerivation = true;

      # Retrieve all packages from the finished package set that have the current package as a dependency and build them
      passthru = passthru // {
        tests =
          passthru.tests or { }
          // filterAttrs (
            name: pkg: self.lib.isUnbrokenAgdaPackage pkg && elem pname (map (pkg: pkg.pname) pkg.buildInputs)
          ) self;
      };

      meta = if meta.broken or false then meta // { hydraPlatforms = platforms.none; } else meta;
    };
in
{
  inherit mkLibraryFile withPackages withPackages';
  mkDerivation = args: stdenv.mkDerivation (args // defaults args);
}
