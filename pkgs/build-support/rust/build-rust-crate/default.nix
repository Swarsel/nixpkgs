# Code for buildRustCrate, a Nix function that builds Rust code, just
# like Cargo, but using Nix instead.
#
# This can be useful for deploying packages with NixOps, and to share
# binary dependencies between projects.

{
  lib,
  stdenv,
  cargo,
  clippy,
  defaultCrateOverrides,
  fetchCrate,
  jq,
  libiconv,
  pkgsBuildBuild,
  rustc,
  # Controls codegen parallelization for all crates.
  # May be overridden on a per-crate level.
  # See <https://doc.rust-lang.org/rustc/codegen-options/index.html#codegen-units>
  defaultCodegenUnits ? 1,
}:

let
  # Create rustc arguments to link against the given list of dependencies
  # and renames.
  #
  # See docs for crateRenames below.
  mkRustcDepArgs =
    dependencies: crateRenames:
    lib.concatMapStringsSep " " (
      dep:
      let
        normalizeName = lib.replaceStrings [ "-" ] [ "_" ];
        extern = normalizeName dep.libName;
        # Find a choice that matches in name and optionally version.
        findMatchOrUseExtern =
          choices:
          lib.findFirst (choice: (!(choice ? version) || choice.version == dep.version or "")) {
            rename = extern;
          } choices;
        name =
          if lib.hasAttr dep.crateName crateRenames then
            let
              choices = crateRenames.${dep.crateName};
            in
            normalizeName (if builtins.isList choices then (findMatchOrUseExtern choices).rename else choices)
          else
            extern;
        opts = lib.optionalString (dep.stdlib or false) "noprelude:";
        filename =
          if lib.any (x: x == "lib" || x == "rlib") dep.crateType then
            "${dep.metadata}.rlib"
          # Adjust lib filename for crates of type proc-macro. Proc macros are compiled/run on the build platform architecture.
          else if (lib.attrByPath [ "procMacro" ] false dep) then
            "${dep.metadata}${stdenv.buildPlatform.extensions.library}"
          else
            "${dep.metadata}${stdenv.hostPlatform.extensions.library}";
      in
      " --extern ${opts}${name}=${dep.lib}/lib/lib${extern}-${filename}"
    ) dependencies;

  # Create feature arguments for rustc.
  mkRustcFeatureArgs = lib.concatMapStringsSep " " (f: ''--cfg feature=\"${f}\"'');

  # Translate a Cargo.toml `[lints]` table into rustc flags.
  #
  # See <https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section>.
  #
  # Cargo normally translates `[lints.<tool>]` entries into `-A`/`-W`/`-D`/`-F`
  # flags when invoking rustc. Since buildRustCrate calls rustc directly we
  # must perform that translation ourselves.
  #
  # Example:
  #
  #   lintsToRustcFlags {
  #     rust = {
  #       unsafe_code = "forbid";
  #       unused = { level = "deny"; priority = -1; };
  #     };
  #     clippy.all = "warn";
  #   }
  #   => [ "-D unused" "-W clippy::all" "-F unsafe_code" ]
  #
  # Entries are sorted by ascending priority (default 0) so that lower-priority
  # groups are emitted first and can be overridden by higher-priority specific
  # lints — matching cargo's behaviour where later rustc flags win.
  lintsToRustcFlags =
    lints:
    let
      levelFlag = {
        allow = "-A";
        deny = "-D";
        forbid = "-F";
        force-warn = "--force-warn";
        warn = "-W";
      };
      toolPrefix = tool: if tool == "rust" then "" else "${tool}::";
      normalize =
        val:
        if builtins.isString val then
          {
            level = val;
            priority = 0;
          }
        else
          { priority = 0; } // val;
      entries = lib.concatMap (
        tool:
        lib.mapAttrsToList (
          name: val:
          let
            e = normalize val;
          in
          {
            inherit (e) priority;
            flag = "${levelFlag.${e.level}} ${toolPrefix tool}${name}";
          }
        ) lints.${tool}
      ) (builtins.attrNames lints);
      sorted = lib.sort (a: b: a.priority < b.priority) entries;
    in
    map (e: e.flag) sorted;

  # Whether we need to use unstable command line flags
  #
  # Currently just needed for standard library dependencies, which have a
  # special "noprelude:" modifier. If in later versions of Rust this is
  # stabilized we can account for that here, too, so we don't opt into
  # instability unnecessarily.
  needUnstableCLI = dependencies: lib.any (dep: dep.stdlib or false) dependencies;

  inherit (import ./log.nix { inherit lib; }) noisily echo_colored;

  configureCrate = import ./configure-crate.nix {
    inherit
      lib
      stdenv
      echo_colored
      noisily
      mkRustcDepArgs
      mkRustcFeatureArgs
      ;
  };

  installCrate = import ./install-crate.nix { inherit stdenv; };
in

/*
  The overridable pkgs.buildRustCrate function.
  *
  * Any unrecognized parameters will be passed as to
  * the underlying stdenv.mkDerivation.
*/
crate_:
lib.makeOverridable
  (
    # The rust compiler to use.
    {
      # Rust build dependencies, i.e. other libraries that were built
      # with buildRustCrate and are used by a build script.
      buildDependencies,
      # Additional build inputs for building this crate.
      #
      # Example: [ pkgs.openssl ]
      buildInputs,
      # Whether to enable building tests.
      # Use true to enable.
      # Default: false
      buildTests,
      # The lint level cap passed to rustc via `--cap-lints`.
      # See <https://doc.rust-lang.org/rustc/lints/levels.html#capping-lints>.
      #
      # rustc honours only the first `--cap-lints` it sees, so appending a
      # second one via `extraRustcOpts` has no effect. Use this parameter
      # instead if you need lints to fire (e.g. when running clippy).
      #
      # When left at `null`, resolves to `"allow"` if `lints` is empty (the
      # usual case for third-party dependencies), or `"forbid"` if `lints`
      # is set (so your own crate's lint policy actually applies).
      #
      # Example: "warn"
      # Default: null (auto: "allow" or "forbid" depending on `lints`)
      capLints,
      # Allows to override the parameters to buildRustCrate
      # for any rust dependency in the transitive build tree.
      #
      # Default: pkgs.defaultCrateOverrides
      #
      # Example:
      #
      # pkgs.defaultCrateOverrides // {
      #   hello = attrs: { buildInputs = [ openssl ]; };
      # }
      crateOverrides,
      # Specify the "extern" name of a library if it differs from the library target.
      # See above for an extended explanation.
      #
      # Default: no renames.
      #
      # Example:
      #
      # `crateRenames` supports two formats.
      #
      # The simple version is an attrset that maps the
      # `crateName`s of the dependencies to their alternative
      # names.
      #
      # ```nix
      # {
      #   my_crate_name = "my_alternative_name";
      #   # ...
      # }
      # ```
      #
      # The extended version is also keyed by the `crateName`s but allows
      # different names for different crate versions:
      #
      # ```nix
      # {
      #   my_crate_name = [
      #       { version = "1.2.3"; rename = "my_alternative_name01"; }
      #       { version = "3.2.3"; rename = "my_alternative_name03"; }
      #   ]
      #   # ...
      # }
      # ```
      #
      # This roughly corresponds to the following snippet in Cargo.toml:
      #
      # ```toml
      # [dependencies]
      # my_alternative_name01 = { package = "my_crate_name", version = "0.1" }
      # my_alternative_name03 = { package = "my_crate_name", version = "0.3" }
      # ```
      #
      # Dependencies which use the lib target name as extern name, do not need
      # to be specified in the crateRenames, even if their crate name differs.
      #
      # Including multiple versions of a crate is very popular during
      # ecosystem transitions, e.g. from futures 0.1 to futures 0.3.
      crateRenames,
      # Rust library dependencies, i.e. other libraries that were built
      # with buildRustCrate.
      dependencies,
      # Rust dev-dependencies, i.e. other libraries that were built
      # with buildRustCrate and are linked only when `buildTests = true`.
      # Mirrors Cargo's `[dev-dependencies]`: ignored for the regular
      # lib/bin build, appended to `dependencies` for the test build.
      #
      # Default: []
      devDependencies,
      # A list of extra options to pass to rustc.
      #
      # Example: [ "-Z debuginfo=2" ]
      # Default: []
      extraRustcOpts,
      # A list of extra options to pass to rustc when building a build.rs.
      #
      # Example: [ "-Z debuginfo=2" ]
      # Default: []
      extraRustcOptsForBuildRs,
      # Extra rustc options for proc-macro crates, replacing
      # `extraRustcOpts`. Lets callers keep instrumentation flags
      # (sanitizers, coverage) off host dylibs, mirroring Cargo's
      # behaviour of not applying RUSTFLAGS to host artifacts.
      # Default: null (inherit `extraRustcOpts`)
      extraRustcOptsForProcMacro,
      # A list of rust/cargo features to enable while building the crate.
      # Example: [ "std" "async" ]
      features,
      # Lint configuration mirroring Cargo.toml's `[lints]` table.
      # See <https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section>.
      #
      # Keys are tool names (`rust`, `clippy`, `rustdoc`); values are attrsets
      # mapping lint names to either a level string (`"allow"`, `"warn"`,
      # `"force-warn"`, `"deny"`, `"forbid"`) or an attrset
      # `{ level = "..."; priority = <int>; }`. Lower priorities are emitted
      # first so that higher-priority (more specific) lints can override them.
      #
      # Setting a non-empty `lints` raises the default `capLints` from
      # `"allow"` to `"forbid"` so the lints actually fire.
      #
      # Example:
      #   {
      #     rust = {
      #       unsafe_code = "forbid";
      #       unused = { level = "deny"; priority = -1; };
      #     };
      #     clippy.all = "warn";
      #   }
      # Default: {}
      lints,
      # Additional native build inputs for building this crate.
      nativeBuildInputs,
      # Passed to stdenv.mkDerivation.
      patches,
      # Passed to stdenv.mkDerivation.
      postBuild,
      # Passed to stdenv.mkDerivation.
      postConfigure,
      # Passed to stdenv.mkDerivation.
      postInstall,
      # Passed to stdenv.mkDerivation.
      postPatch,
      # Passed to stdenv.mkDerivation.
      postUnpack,
      # Passed to stdenv.mkDerivation.
      preBuild,
      # Passed to stdenv.mkDerivation.
      preConfigure,
      # Passed to stdenv.mkDerivation.
      preInstall,
      # Passed to stdenv.mkDerivation.
      prePatch,
      # Passed to stdenv.mkDerivation.
      preUnpack,
      # Whether to build a release version (`true`) or a debug
      # version (`false`). Debug versions are faster to build
      # but might be much slower at runtime.
      release,
      # Whether to compile the crate's library, binary, and test targets with
      # `clippy-driver` instead of `rustc`. Build scripts (`build.rs`) keep
      # plain `rustc` — they are typically auto-generated and clippy findings
      # there are not actionable.
      #
      # `clippy-driver` wraps `rustc_driver` with extra lint passes and emits
      # link-compatible `.rlib`/`.rmeta`, so dependency crates built with plain
      # `rustc` are still usable; only the crate being linted needs this flag.
      #
      # Note that the default `capLints` of `"allow"` suppresses ALL lints,
      # including clippy's. Set `capLints = "warn"` (or `"forbid"`) or supply
      # a `lints` table — otherwise `useClippy` is a silent no-op. Lint flags
      # such as `-D warnings` or `-W clippy::pedantic` go through the regular
      # `extraRustcOpts` (clippy-driver forwards rustc flags unchanged).
      #
      # Example: true
      # Default: false
      useClippy,
      # Whether to print rustc invocations etc.
      #
      # Example: false
      # Default: true
      verbose,
      # The cargo package to use for getting some metadata.
      #
      # Default: pkgs.cargo
      cargo ? cargo,
      # The clippy package providing `clippy-driver`. Only consulted when
      # `useClippy = true`. Override this together with `rust` when using a
      # toolchain (rust-overlay, Fenix) that bundles its own `clippy-driver`,
      # so the sysroot matches.
      #
      # Default: pkgs.clippy
      clippy ? clippy,
      rust ? rustc,
    }:

    let
      crate = crate_ // (lib.attrByPath [ crate_.crateName ] (attr: { }) crateOverrides crate_);
      dependencies_ = dependencies;
      buildDependencies_ = buildDependencies;
      devDependencies_ = devDependencies;
      processedAttrs = [
        "src"
        "propagatedBuildInputs"
        "nativeBuildInputs"
        "buildInputs"
        "crateBin"
        "crateLib"
        "libName"
        "libPath"
        "buildDependencies"
        "dependencies"
        "devDependencies"
        "features"
        "crateRenames"
        "crateName"
        "version"
        "build"
        "authors"
        "colors"
        "edition"
        "buildTests"
        "codegenUnits"
        "links"
        "capLints"
        "lints"
      ];
      extraDerivationAttrs = removeAttrs crate processedAttrs;
      nativeBuildInputs_ = nativeBuildInputs;
      buildInputs_ = buildInputs;
      extraRustcOpts_ = extraRustcOpts;
      extraRustcOptsForBuildRs_ = extraRustcOptsForBuildRs;
      extraRustcOptsForProcMacro_ = extraRustcOptsForProcMacro;
      buildTests_ = buildTests;
      procMacro = lib.attrByPath [ "procMacro" ] false crate;
      # For proc-macros, prefer the *ForProcMacro variant at each level
      # (crate attr, override arg) and fall back to extraRustcOpts.
      crateExtraRustcOpts =
        if procMacro && crate ? extraRustcOptsForProcMacro then
          crate.extraRustcOptsForProcMacro
        else
          crate.extraRustcOpts or [ ];
      overrideExtraRustcOpts =
        if procMacro && extraRustcOptsForProcMacro_ != null then
          extraRustcOptsForProcMacro_
        else
          extraRustcOpts_;
      resolvedLints = crate.lints or lints;
      lintFlags = lintsToRustcFlags resolvedLints;
      resolvedCapLints =
        let
          requested = crate.capLints or capLints;
        in
        if requested != null then
          requested
        else if resolvedLints != { } then
          "forbid"
        else
          "allow";

      # crate2nix has a hack for the old bash based build script that did split
      # entries at `,`. No we have to work around that hack.
      # https://github.com/kolloch/crate2nix/blame/5b19c1b14e1b0e5522c3e44e300d0b332dc939e7/crate2nix/templates/build.nix.tera#L89
      crateBin = lib.filter (bin: !(bin ? name && bin.name == ",")) (crate.crateBin or [ ]);
      hasCrateBin = crate ? crateBin;

      buildCrate = import ./build-crate.nix {
        inherit
          lib
          stdenv
          mkRustcDepArgs
          mkRustcFeatureArgs
          needUnstableCLI
          ;

        rustc = rust;
      };
    in
    stdenv.mkDerivation (
      rec {

        inherit (crate) crateName;

        inherit
          preUnpack
          postUnpack
          prePatch
          patches
          postPatch
          preConfigure
          postConfigure
          preBuild
          postBuild
          preInstall
          postInstall
          buildTests
          ;

        version = crate.version;
        src = crate.src or (fetchCrate { inherit (crate) crateName version sha256; });

        # depending on the test setting we are either producing something with bins
        # and libs or just test binaries
        outputs =
          if buildTests then
            [ "out" ]
          else
            [
              "out"
              "lib"
            ];

        nativeBuildInputs = [
          rust
          cargo
          jq
        ]
        ++ lib.optional useClippy clippy
        ++ lib.optionals stdenv.hasCC [ stdenv.cc ]
        ++ lib.optionals stdenv.buildPlatform.isDarwin [ libiconv ]
        ++ (crate.nativeBuildInputs or [ ])
        ++ nativeBuildInputs_;

        buildInputs =
          lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ]
          ++ (crate.buildInputs or [ ])
          ++ buildInputs_
          ++ completePropagatedBuildInputs;

        buildPhase = buildCrate {
          inherit
            crateName
            version
            dependencies
            crateFeatures
            crateRenames
            libName
            release
            libPath
            crateType
            metadata
            hasCrateBin
            crateBin
            verbose
            colors
            extraRustcOpts
            buildTests
            codegenUnits
            capLints
            useClippy
            ;
        };

        installPhase = installCrate crateName metadata buildTests;
        build = crate.build or "";
        buildDependencies = map lib.getLib buildDependencies_;
        capLints = resolvedCapLints;
        codegenUnits = if crate ? codegenUnits then crate.codegenUnits else defaultCodegenUnits;
        colors = lib.attrByPath [ "colors" ] "always" crate;

        completeBuildDeps = lib.unique (
          buildDependencies
          ++ lib.concatMap (dep: dep.completeBuildDeps ++ dep.completeDeps) buildDependencies
        );

        completeDeps = lib.unique (dependencies ++ lib.concatMap (dep: dep.completeDeps) dependencies);

        # Propagated native build inputs from this crate and all transitive Rust
        # dependencies. Analogous to completeDeps but for native library deps:
        # a crate can declare `propagatedBuildInputs` in its override and they
        # will automatically be added to the buildInputs of every crate that
        # depends on it, without having to repeat them up the dependency tree.
        completePropagatedBuildInputs = lib.unique (
          (crate.propagatedBuildInputs or [ ])
          ++ lib.concatMap (dep: dep.completePropagatedBuildInputs or [ ]) dependencies
        );

        configurePhase = configureCrate {
          inherit
            crateName
            crateType
            buildDependencies
            completeDeps
            completeBuildDeps
            crateDescription
            crateFeatures
            crateRenames
            libName
            build
            workspace_member
            release
            libPath
            crateVersion
            crateLinks
            extraLinkFlags
            extraRustcOptsForBuildRs
            capLints
            crateLicense
            crateLicenseFile
            crateReadme
            crateRepository
            crateRustVersion
            crateAuthors
            crateHomepage
            verbose
            colors
            codegenUnits
            ;
        };

        crateAuthors = if crate ? authors && lib.isList crate.authors then crate.authors else [ ];
        crateDescription = crate.description or "";

        # Create a list of features that are enabled by the crate itself and
        # through the features argument of buildRustCrate. Exclude features
        # with a forward slash, since they are passed through to dependencies,
        # and dep: features, since they're internal-only and do nothing except
        # enable optional dependencies.
        crateFeatures = lib.optionals (crate ? features) (
          builtins.filter (f: !(lib.hasInfix "/" f || lib.hasPrefix "dep:" f)) (crate.features ++ features)
        );

        crateHomepage = crate.homepage or "";
        crateLicense = crate.license or "";
        crateLicenseFile = crate.license-file or "";
        crateLinks = crate.links or "";
        crateReadme = crate.readme or "";
        crateRepository = crate.repository or "";
        crateRustVersion = crate.rust-version or "";

        crateType =
          if procMacro then
            [ "proc-macro" ]
          else if lib.attrByPath [ "plugin" ] false crate then
            [ "dylib" ]
          else
            (crate.type or [ "lib" ]);

        crateVersion = crate.version;
        # Dev-dependencies are only linked when building tests, mirroring
        # Cargo. When buildTests is false this is a no-op, so the metadata
        # hash and store path of normal lib/bin builds are unchanged.
        dependencies = map lib.getLib (dependencies_ ++ lib.optionals buildTests_ devDependencies_);
        depsBuildBuild = [ pkgsBuildBuild.stdenv.cc ];
        dontStrip = !release;
        edition = crate.edition or null;
        extraLinkFlags = lib.concatStringsSep " " (crate.extraLinkFlags or [ ]);

        extraRustcOpts =
          crateExtraRustcOpts
          ++ overrideExtraRustcOpts
          ++ lintFlags
          ++ (lib.optional (edition != null) "--edition ${edition}");

        extraRustcOptsForBuildRs =
          lib.optionals (crate ? extraRustcOptsForBuildRs) crate.extraRustcOptsForBuildRs
          ++ extraRustcOptsForBuildRs_
          ++ lintFlags
          ++ (lib.optional (edition != null) "--edition ${edition}");

        libName = if crate ? libName then crate.libName else crate.crateName;
        libPath = lib.optionalString (crate ? libPath) crate.libPath;

        # Seed the symbol hashes with something unique every time.
        # https://doc.rust-lang.org/1.0.0/rustc/metadata/loader/index.html#frobbing-symbols
        metadata =
          let
            depsMetadata = lib.foldl' (str: dep: str + dep.metadata) "" (dependencies ++ buildDependencies);
            hashedMetadata = builtins.hashString "sha256" (
              crateName
              + "-"
              + crateVersion
              + "___"
              + toString (mkRustcFeatureArgs crateFeatures)
              + "___"
              + depsMetadata
              + "___"
              + stdenv.hostPlatform.rust.rustcTarget
            );
          in
          lib.substring 0 10 hashedMetadata;

        name = "rust_${crate.crateName}-${crate.version}${lib.optionalString buildTests_ "-test"}";
        outputDev = if buildTests then [ "out" ] else [ "lib" ];
        # We need to preserve metadata in .rlib, which might get stripped on macOS. See https://github.com/NixOS/nixpkgs/issues/218712
        stripExclude = [ "*.rlib" ];
        # Either set to a concrete sub path to the crate root
        # or use `null` for auto-detect.
        workspace_member = crate.workspace_member or ".";

        meta = {
          badPlatforms = [
            # Rust is currently unable to target the n32 ABI
            lib.systems.inspect.patterns.isMips64n32
          ];

          mainProgram = crateName;
        };
      }
      // extraDerivationAttrs
    )
  )
  {
    patches = crate_.patches or [ ];
    postPatch = crate_.postPatch or "";
    nativeBuildInputs = [ ];
    buildInputs = [ ];
    preConfigure = crate_.preConfigure or "";
    postConfigure = crate_.postConfigure or "";
    preBuild = crate_.preBuild or "";
    postBuild = crate_.postBuild or "";
    preInstall = crate_.preInstall or "";
    postInstall = crate_.postInstall or "";
    buildDependencies = crate_.buildDependencies or [ ];
    buildTests = crate_.buildTests or false;
    capLints = null;
    cargo = crate_.cargo or cargo;
    clippy = crate_.clippy or clippy;
    crateOverrides = defaultCrateOverrides;
    crateRenames = crate_.crateRenames or { };
    dependencies = crate_.dependencies or [ ];
    devDependencies = crate_.devDependencies or [ ];
    extraRustcOpts = [ ];
    extraRustcOptsForBuildRs = [ ];
    extraRustcOptsForProcMacro = null;
    features = [ ];
    lints = { };
    postUnpack = crate_.postUnpack or "";
    prePatch = crate_.prePatch or "";
    preUnpack = crate_.preUnpack or "";
    release = crate_.release or true;
    rust = crate_.rust or rustc;
    useClippy = crate_.useClippy or false;
    verbose = crate_.verbose or true;
  }
