{
  lib,
  buildEnv,
  # common runtime dependencies
  coreutils,
  gawk,
  ghostscript,
  gnugrep,
  gnused,
  libfaketime,
  makeFontsConf,
  makeWrapper,
  perl,
  runCommand,
  # texlive package set
  tl,
  tlpdbVersion,
  toTLPkgSets,
}:

lib.fix (
  buildTeXEnv:
  {
    # emulate the old texlive.combine (e.g. add man pages to main output)
    __combine ? false,
    ### texlive.combine backward compatibility
    __extraName ? "combined",
    __extraVersion ? "",
    # build only the formats of a package (for internal use!)
    __formatsOf ? null,
    # adjust behavior further if called from the texlive.combine wrapper
    __fromCombineWrapper ? false,
    requiredTeXPackages ? ps: [ ps.scheme-infraonly ],
  }:
  buildEnv (
    finalAttrs:

    let
      # if necessary, convert old style { pkgs = [ ... ]; } packages to attribute sets
      isOldPkgList = p: !p.outputSpecified or false && p ? pkgs && builtins.all (p: p ? tlType) p.pkgs;
      ensurePkgSets =
        ps:
        if !finalAttrs.passthru.__fromCombineWrapper && builtins.any isOldPkgList ps then
          let
            oldPkgLists = builtins.partition isOldPkgList ps;
          in
          oldPkgLists.wrong ++ lib.concatMap toTLPkgSets oldPkgLists.right
        else
          ps;

      pkgList = rec {
        # resolve dependencies of the packages that affect the runtime
        all =
          let
            packages = ensurePkgSets (finalAttrs.passthru.requiredTeXPackages tl);
            runtime = builtins.partition (
              p:
              p.outputSpecified or false
              -> builtins.elem (p.tlOutputName or p.outputName) [
                "out"
                "tex"
                "tlpkg"
              ]
            ) packages;
            keySet = p: {
              inherit p;

              key =
                p.pname or p.name
                + lib.optionalString (p.outputSpecified or false) ("-" + p.tlOutputName or p.outputName or "");

              tlDeps =
                if p ? tlDeps then
                  (if builtins.isFunction p.tlDeps then p.tlDeps tl else ensurePkgSets p.tlDeps)
                else
                  [ ];
            };
          in
          # texlive.combine: the wrapper already resolves all dependencies
          if finalAttrs.passthru.__fromCombineWrapper then
            finalAttrs.passthru.requiredTeXPackages null
          else
            builtins.catAttrs "p" (
              builtins.genericClosure {
                operator = p: map keySet p.tlDeps;
                startSet = map keySet runtime.right;
              }
            )
            ++ runtime.wrong;

        # split binary and tlpkg from tex, texdoc, texsource
        bin =
          if finalAttrs.passthru.__fromCombineWrapper then
            builtins.filter (p: p.tlType == "bin") all # texlive.combine: legacy filter
          else
            otherOutputs.out or [ ] ++ specifiedOutputs.out or [ ];

        # packages that contribute to config files and formats
        fontMaps = lib.filter (p: p ? fontMaps && (p.tlOutputName or p.outputName == "tex")) nonbin;

        formatPkgs = lib.filter (
          p:
          p ? formats
          && (p.outputSpecified or false -> p.tlOutputName or p.outputName == "tex")
          && builtins.any (f: f.enabled or true) p.formats
        ) all;

        formats = map (
          p:
          buildTeXEnv {
            __formatsOf = p;

            requiredTeXPackages =
              ps:
              [
                ps.scheme-infraonly
                p
              ]
              ++ hyphenPatterns;
          }
        ) sortedFormatPkgs;

        hyphenPatterns = lib.filter (
          p: p ? hyphenPatterns && (p.tlOutputName or p.outputName == "tex")
        ) nonbin;

        # outputs that do not become part of the environment
        nonEnvOutputs = lib.subtractLists [ "out" "tex" "texdoc" "texsource" "tlpkg" ] otherOutputNames;

        nonbin =
          if finalAttrs.passthru.__fromCombineWrapper then
            builtins.filter (p: p.tlType != "bin" && p.tlType != "tlpkg") all # texlive.combine: legacy filter
          else
            (
              if finalAttrs.__combine then # texlive.combine: emulate old input ordering to avoid rebuilds
                lib.concatMap (
                  p:
                  lib.optional (p ? tex) p.tex
                  ++ lib.optional ((finalAttrs.withDocs || p ? man) && p ? texdoc) p.texdoc
                  ++ lib.optional (finalAttrs.withSources && p ? texsource) p.texsource
                ) specified.wrong
              else
                otherOutputs.tex or [ ]
                ++ lib.optionals finalAttrs.withDocs (otherOutputs.texdoc or [ ])
                ++ lib.optionals finalAttrs.withSources (otherOutputs.texsource or [ ])
            )
            ++ specifiedOutputs.tex or [ ]
            ++ specifiedOutputs.texdoc or [ ]
            ++ specifiedOutputs.texsource or [ ];

        otherOutputNames = builtins.catAttrs "key" (
          builtins.genericClosure {
            operator = _: [ ];

            startSet = map (key: { inherit key; }) (
              lib.concatLists (builtins.catAttrs "outputs" specified.wrong)
            );
          }
        );

        otherOutputs = lib.genAttrs otherOutputNames (n: builtins.catAttrs n specified.wrong);

        outputsToInstall = builtins.catAttrs "key" (
          builtins.genericClosure {
            operator = _: [ ];

            startSet = map (key: { inherit key; }) (
              [ "out" ]
              ++ lib.optional (otherOutputs ? man) "man"
              ++ lib.concatLists (builtins.catAttrs "outputsToInstall" (builtins.catAttrs "meta" specified.wrong))
            );
          }
        );

        sortedFontMaps = builtins.sort (a: b: a.pname < b.pname) fontMaps;

        sortedFormatPkgs =
          if __formatsOf != null then [ __formatsOf ] else builtins.sort (a: b: a.pname < b.pname) formatPkgs;

        sortedHyphenPatterns = builtins.sort (a: b: a.pname < b.pname) hyphenPatterns;
        # group the specified outputs
        specified = builtins.partition (p: p.outputSpecified or false) all;
        specifiedOutputs = lib.groupBy (p: p.tlOutputName or p.outputName) specified.right;

        tlpkg =
          if finalAttrs.passthru.__fromCombineWrapper then
            builtins.filter (p: p.tlType == "tlpkg") all # texlive.combine: legacy filter
          else
            otherOutputs.tlpkg or [ ] ++ specifiedOutputs.tlpkg or [ ];
      };

      # list generated by inspecting `grep -IR '\([^a-zA-Z]\|^\)gs\( \|$\|"\)' "$TEXMFDIST"/scripts`
      # and `grep -IR rungs "$TEXMFDIST"`
      # and ignoring luatex, perl, and shell scripts (those must be patched using postFixup)
      needsGhostscript = lib.any (
        p:
        lib.elem p.pname [
          "context"
          "dvipdfmx"
          "latex-papersize"
          "lyluatex"
        ]
      ) pkgList.bin;

      pname =
        if finalAttrs.__combine then
          "texlive-${finalAttrs.passthru.__extraName}" # texlive.combine: old name
        else
          "texlive";
      version =
        if finalAttrs.__combine then
          "${toString tlpdbVersion.year}${finalAttrs.passthru.__extraVersion}" # texlive.combine: old version
        else
          "${toString tlpdbVersion.year}-r${toString tlpdbVersion.revision}-"
          + (lib.optionalString tlpdbVersion.frozen "final-")
          + (if __formatsOf != null then "${__formatsOf.pname}-fmt" else "env");

      name = "${pname}-${version}";

      texmfdist = buildEnv {
        # mktexlsr
        nativeBuildInputs = [
          tl.texlive-scripts # for mktexlsr.pl with --sort support
          perl
        ];

        postBuild = # generate ls-R database
          ''
            perl ${tl.texlive-scripts.tex}/scripts/texlive/mktexlsr.pl --sort "$out"
          '';

        name = "${name}-texmfdist";
        # remove fake derivations (without 'outPath') to avoid undesired build dependencies
        paths = builtins.catAttrs "outPath" pkgList.nonbin;
      };

      tlpkg = buildEnv {
        name = "${name}-tlpkg";
        # remove fake derivations (without 'outPath') to avoid undesired build dependencies
        paths = builtins.catAttrs "outPath" pkgList.tlpkg;
      };

      # the 'non-relocated' packages must live in $TEXMFROOT/texmf-dist
      # and sometimes look into $TEXMFROOT/tlpkg (notably fmtutil, updmap look for perl modules in both)
      texmfroot =
        runCommand "${name}-texmfroot"
          {
            inherit texmfdist tlpkg;
          }
          ''
            mkdir -p "$out"
            ln -s "$texmfdist" "$out"/texmf-dist
            ln -s "$tlpkg" "$out"/tlpkg
          '';

      # texlive.combine: expose info and man pages in usual /share/{info,man} location
      doc = buildEnv {
        extraPrefix = "/share";
        name = "${name}-doc";
        paths = [ (texmfdist.outPath + "/doc") ];

        pathsToLink = [
          "/info"
          "/man"
        ];
      };

      meta = {
        description =
          "TeX Live environment"
          + lib.optionalString finalAttrs.withDocs " with documentation"
          + lib.optionalString (finalAttrs.withDocs && finalAttrs.withSources) " and"
          + lib.optionalString finalAttrs.withSources " with sources";

        longDescription =
          "Contains the following packages and their transitive dependencies:\n - "
          + lib.concatMapStringsSep "\n - " (
            p:
            p.pname + (lib.optionalString (p.outputSpecified or false) " (${p.tlOutputName or p.outputName})")
          ) (finalAttrs.passthru.requiredTeXPackages tl);

        platforms = lib.platforms.all;
      };

      # other outputs
      nonEnvOutputs = lib.genAttrs pkgList.nonEnvOutputs (
        outName:
        buildEnv {
          inherit name;

          derivationArgs = {
            inherit meta passthru;
            outputs = [ outName ];

            # force the output to be ${outName} or nix-env will not work
            preHook = ''
              export out="''${${outName}}"
            '';
          };

          paths = builtins.catAttrs "outPath" (
            pkgList.otherOutputs.${outName} or [ ] ++ pkgList.specifiedOutputs.${outName} or [ ]
          );
        }
      );

      passthru = {
        inherit
          requiredTeXPackages
          __fromCombineWrapper
          __extraName
          __extraVersion
          ;

        __overrideTeXConfig = lib.warn "__overrideTeXConfig is deprecated, please switch to overrideAttrs" (
          newArgs:
          let
            # arguments of buildTeXEnv before deprecation of __overrideTeXConfig
            prevArgs = {
              inherit (finalAttrs)
                __combine
                ;

              inherit (finalAttrs.passthru)
                requiredTeXPackages
                __extraName
                __extraVersion
                __fromCombineWrapper
                ;
            }
            // lib.optionalAttrs (finalAttrs ? withDocs) { inherit (finalAttrs) withDocs; }
            // lib.optionalAttrs (finalAttrs ? withSources) { inherit (finalAttrs) withSources; };
            appliedArgs = prevArgs // (if builtins.isFunction newArgs then newArgs prevArgs else newArgs);
          in
          finalAttrs.finalPackage.overrideAttrs (
            prevAttrs:
            {
              inherit (appliedArgs) __combine;

              passthru = prevAttrs.passthru // {
                inherit (appliedArgs)
                  requiredTeXPackages
                  __extraName
                  __extraVersion
                  ;

                __fromCombineWrapper = false;
              };
            }
            // lib.optionalAttrs (appliedArgs ? withDocs) { inherit (appliedArgs) withDocs; }
            // lib.optionalAttrs (appliedArgs ? withSources) { inherit (appliedArgs) withSources; }
          )
        );

        # useful for inclusion in the `fonts.packages` nixos option or for use in devshells
        fonts = "${texmfroot}/texmf-dist/fonts";

        # This is set primarily to help find-tarballs.nix to do its job
        includedTeXPackages = builtins.filter lib.isDerivation (
          pkgList.bin
          ++ pkgList.nonbin
          ++ lib.optionals (!finalAttrs.passthru.__fromCombineWrapper) (
            lib.concatMap (
              n: (pkgList.otherOutputs.${n} or [ ] ++ pkgList.specifiedOutputs.${n} or [ ])
            ) pkgList.nonEnvOutputs
          )
        );

        withPackages =
          reqs:
          finalAttrs.finalPackage.overrideAttrs (prevAttrs: {
            passthru = prevAttrs.passthru // {
              __fromCombineWrapper = false;
              requiredTeXPackages = ps: reqs ps ++ prevAttrs.passthru.requiredTeXPackages ps;
            };
          });
      };

      # TeXLive::TLOBJ::fmtutil_cnf_lines
      fmtutilLine =
        {
          engine,
          name,
          enabled ? true,
          options ? "",
          patterns ? [ "-" ],
          ...
        }:
        lib.optionalString (!enabled) "#! "
        + "${name} ${engine} ${lib.concatStringsSep "," patterns} ${options}";
      fmtutilLines =
        { formats, pname, ... }:
        [
          "#"
          "# from ${pname}:"
        ]
        ++ map fmtutilLine formats;

      # TeXLive::TLOBJ::language_dat_lines
      langDatLine =
        {
          file,
          name,
          synonyms ? [ ],
          ...
        }:
        [ "${name} ${file}" ] ++ map (s: "=" + s) synonyms;
      langDatLines =
        { hyphenPatterns, pname, ... }:
        [ "% from ${pname}:" ] ++ builtins.concatMap langDatLine hyphenPatterns;

      # TeXLive::TLOBJ::language_def_lines
      # see TeXLive::TLUtils::parse_AddHyphen_line for default values
      langDefLine =
        {
          file,
          name,
          lefthyphenmin ? "",
          righthyphenmin ? "",
          synonyms ? [ ],
          ...
        }:
        map (
          n:
          "\\addlanguage{${n}}{${file}}{}{${if lefthyphenmin == "" then "2" else lefthyphenmin}}{${
            if righthyphenmin == "" then "3" else righthyphenmin
          }}"
        ) ([ name ] ++ synonyms);
      langDefLines =
        { hyphenPatterns, pname, ... }:
        [ "% from ${pname}:" ] ++ builtins.concatMap langDefLine hyphenPatterns;

      # TeXLive::TLOBJ::language_lua_lines
      # see TeXLive::TLUtils::parse_AddHyphen_line for default values
      langLuaLine =
        {
          file,
          name,
          lefthyphenmin ? "",
          righthyphenmin ? "",
          synonyms ? [ ],
          ...
        }@args:
        ''
          ''\t['${name}'] = {
          ''\t''\tloader = '${file}',
          ''\t''\tlefthyphenmin = ${if lefthyphenmin == "" then "2" else lefthyphenmin},
          ''\t''\trighthyphenmin = ${if righthyphenmin == "" then "3" else righthyphenmin},
          ''\t''\tsynonyms = { ${lib.concatStringsSep ", " (map (s: "'${s}'") synonyms)} },
        ''
        + lib.optionalString (args ? file_patterns) "\t\tpatterns = '${args.file_patterns}',\n"
        + lib.optionalString (args ? file_exceptions) "\t\thyphenation = '${args.file_exceptions}',\n"
        + lib.optionalString (args ? luaspecial) "\t\tspecial = '${args.luaspecial}',\n"
        + "\t},";
      langLuaLines =
        { hyphenPatterns, pname, ... }: [ "-- from ${pname}:" ] ++ map langLuaLine hyphenPatterns;

      assembleConfigLines = f: packages: builtins.concatStringsSep "\n" (builtins.concatMap f packages);

      updmapLines = { fontMaps, pname, ... }: [ "# from ${pname}:" ] ++ fontMaps;

    in
    {

      inherit name;

      postBuild = ''
        . "${./build-tex-env.sh}"
      '';

      derivationArgs = {
        inherit passthru __combine;
        inherit texmfdist texmfroot;

        # use attrNames, attrValues to ensure the two lists are sorted in the same way
        outputs = [
          "out"
        ]
        ++ lib.optionals (!finalAttrs.__combine && __formatsOf == null) (builtins.attrNames nonEnvOutputs);

        strictDeps = true;

        nativeBuildInputs = [
          makeWrapper
          libfaketime
          tl."texlive.infra" # mktexlsr
          tl.texlive-scripts # fmtutil, updmap
          tl.texlive-scripts-extra # texlinks
          perl
        ];

        buildInputs = [
          coreutils
          gawk
          gnugrep
          gnused
        ]
        ++ lib.optional needsGhostscript ghostscript;

        __formatsOf = __formatsOf.pname or null;
        allowSubstitutes = true;
        fmtutilCnf = assembleConfigLines fmtutilLines pkgList.sortedFormatPkgs;
        fontconfigFile = makeFontsConf { fontDirectories = [ "${texmfroot}/texmf-dist/fonts" ]; };
        languageDat = assembleConfigLines langDatLines pkgList.sortedHyphenPatterns;
        languageDef = assembleConfigLines langDefLines pkgList.sortedHyphenPatterns;
        languageLua = assembleConfigLines langLuaLines pkgList.sortedHyphenPatterns;

        otherOutputs = lib.optionals (!finalAttrs.__combine && __formatsOf == null) (
          builtins.attrValues nonEnvOutputs
        );

        postactionScripts = builtins.catAttrs "postactionScript" pkgList.tlpkg;
        preferLocalBuild = false;
        updmapCfg = assembleConfigLines updmapLines pkgList.sortedFontMaps;
        # whether to include doc, source containers
        withDocs = false;
        withSources = false;

        meta =
          meta
          // lib.optionalAttrs (!finalAttrs.__combine && __formatsOf == null) {
            inherit (pkgList) outputsToInstall;
          };
      };

      # remove fake derivations (without 'outPath') to avoid undesired build dependencies
      paths =
        builtins.catAttrs "outPath" pkgList.bin
        ++ lib.optionals (!finalAttrs.__combine && __formatsOf == null) pkgList.formats
        ++ lib.optional finalAttrs.__combine doc;

      pathsToLink = [
        "/"
        "/share/texmf-var/scripts"
        "/share/texmf-var/tex/generic/config"
        "/share/texmf-var/web2c"
        "/share/texmf-config"
        "/bin" # ensure these are writeable directories
      ];
    }
  )
)
