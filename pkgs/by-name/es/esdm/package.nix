{
  lib,
  stdenv,
  fetchFromGitHub,
  botan3,
  fuse3,
  jitterentropy,
  libkcapi,
  libselinux,
  meson,
  ninja,
  openssl,
  pkg-config,
  protobufc,
  ais2031 ? true, # set the seeding strategy to be compliant with AIS 20/31
  auxHasFullEntropy ? false, # is already conditioned data inserted into aux pool?
  cryptoBackend ? "botan", # set backend for hash and drbg operations
  drngMaxReseedBits ? lib.fromHexString "0xffffffff",
  # DRNG-related options
  drngReseedThresholdBits ? lib.fromHexString "0xffffffff",
  esCPU ? true, # enable support for the entropy source: cpu-based entropy
  esCPUEntropyRate ? 256, # amount of entropy to account for cpu rng source
  esHwrand ? true, # enable support for the entropy source: /dev/hwrng
  esHwrandEntropyRate ? 256, # amount of entropy to account for /dev/hwrng-based sources
  esIRQ ? false, # enable support for the entropy source: interrupt-based entropy
  esIRQEntropyRate ? 256, # amount of entropy to account for interrupt-based source (only set irq XOR sched != 0)
  # entropy sources
  esJitterRng ? true, # enable support for the entropy source: jitter rng (running in user space)
  esJitterRngAllCaches ? false, # use all caches in calculating size of memory buffer?
  esJitterRngEntropyBlocks ? 128, # number of cached entropy blocks for jitterentropy
  esJitterRngEntropyRate ? 256, # amount of entropy to account for jitter rng source
  esJitterRngHashLoopCount ? -1, # set increased hashloop count, -1 disables it
  esJitterRngKernel ? false, # enable support for the entropy source: jitter rng (running in kernel space)
  esJitterRngKernelEntropyRate ? 256, # amount of entropy to account for kernel jitter rng source
  esJitterRngMaxMem ? -1, # set static maximum size of memory buffer, -1 disables it
  esJitterRngNtg1 ? false, # configures jitterentropy NTG.1 mode
  esJitterRngOsr ? 3, # set larger oversampling rate if necessary, (default 3)
  esKernel ? false, # enable support for the entropy source: kernel-based entropy
  esKernelEntropyRate ? 256, # amount of entropy to account for kernel-based source
  esSched ? false, # enable support for the entropy source: scheduler-based entropy
  esSchedEntropyRate ? 0, # amount of entropy to account for interrupt-based source (only set irq XOR sched != 0)
  esTPM2 ? true, # enable support for the entropy source: TPM-based entropy
  esTPM2EntropyRate ? 256, # amount of entropy to account for TPM-based source
  fips140 ? false, # enable FIPS 140 checksum support
  linuxDevFiles ? true, # enable linux /dev/random and /dev/urandom support
  linuxGetRandom ? true, # enable linux getrandom support
  linuxKernelReseedEntropyRate ? 512, # how many bits to account on kernel (re-)seeding
  # kernel seeding
  linuxKernelReseedInterval ? 60, # how often to push entropy into Linux kernel, iff seeder service is started
  maxThreads ? 64, # number of RPC handler threads
  numAuxPools ? 128, # use multiple hash pools for e.g. smartcard input
  openSSLRandProvider ? true, # build ESDM provider for OpenSSL 3.x
  # A more detailed explanation of the following meson build options can be found
  # in the source code of esdm.
  # A brief explanation is given.
  # general options
  selinux ? false, # enable selinux support
  sp80090c ? true, # set compliance with NIST SP800-90C
  validationHelpers ? true, # used to analyze entropy output from esdm_es
}:

assert cryptoBackend == "openssl" || cryptoBackend == "botan";

stdenv.mkDerivation (finalAttrs: {
  pname = "esdm";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "esdm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0s9YOqa+sn0rk5YoMWZczO1TB5/wpbFsdkaVWFf4ipI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs =
    lib.optional (cryptoBackend == "botan") botan3
    ++ lib.optional (cryptoBackend == "openssl" || openSSLRandProvider) openssl
    ++ lib.optional selinux libselinux
    ++ lib.optional esJitterRng jitterentropy
    ++ lib.optional linuxDevFiles fuse3
    ++ lib.optional esJitterRngKernel libkcapi;

  propagatedBuildInputs = [ protobufc ];

  mesonFlags = [
    (lib.mesonBool "b_lto" true)
    (lib.mesonBool "fips140" fips140)
    (lib.mesonBool "ais2031" ais2031)
    (lib.mesonBool "sp80090c" sp80090c)
    (lib.mesonEnable "node" true) # multiple DRNGs
    (lib.mesonEnable "systemd" true) # systemd notify and socket support
    (lib.mesonOption "threading_max_worker_threads" (toString maxThreads))
    (lib.mesonOption "crypto_backend" cryptoBackend)
    (lib.mesonEnable "linux-devfiles" linuxDevFiles)
    (lib.mesonEnable "linux-getrandom" linuxGetRandom)
    (lib.mesonEnable "es_jent" esJitterRng)
    (lib.mesonOption "es_jent_entropy_rate" (toString esJitterRngEntropyRate))
    (lib.mesonOption "es_jent_entropy_blocks" (toString esJitterRngEntropyBlocks))
    (lib.mesonEnable "es_jent_ntg1" esJitterRngNtg1)
    (lib.mesonEnable "es_jent_all_caches" esJitterRngAllCaches)
    (lib.mesonOption "es_jent_max_mem" (toString esJitterRngMaxMem))
    (lib.mesonOption "es_jent_hash_loop_count" (toString esJitterRngHashLoopCount))
    (lib.mesonOption "es_jent_osr" (toString esJitterRngOsr))
    (lib.mesonEnable "es_jent_kernel" esJitterRngKernel)
    (lib.mesonOption "es_jent_kernel_entropy_rate" (toString esJitterRngKernelEntropyRate))
    (lib.mesonEnable "es_cpu" esCPU)
    (lib.mesonOption "es_cpu_entropy_rate" (toString esCPUEntropyRate))
    (lib.mesonEnable "es_kernel" esKernel)
    (lib.mesonOption "es_kernel_entropy_rate" (toString esKernelEntropyRate))
    (lib.mesonEnable "es_irq" esIRQ)
    (lib.mesonOption "es_irq_entropy_rate" (toString esIRQEntropyRate))
    (lib.mesonEnable "es_sched" esSched)
    (lib.mesonOption "es_sched_entropy_rate" (toString esSchedEntropyRate))
    (lib.mesonEnable "es_hwrand" esHwrand)
    (lib.mesonOption "es_hwrand_entropy_rate" (toString esHwrandEntropyRate))
    (lib.mesonEnable "es_tpm2" esTPM2)
    (lib.mesonOption "es_tpm2_entropy_rate" (toString esTPM2EntropyRate))
    (lib.mesonEnable "selinux" selinux)
    (lib.mesonEnable "openssl-rand-provider" openSSLRandProvider)
    (lib.mesonOption "linux-reseed-interval" (toString linuxKernelReseedInterval))
    (lib.mesonOption "linux-reseed-entropy-count" (toString linuxKernelReseedEntropyRate))
    (lib.mesonEnable "validation-helpers" validationHelpers)
    (lib.mesonOption "num-aux-pools" (toString numAuxPools))
    (lib.mesonEnable "aux-has-full-entropy" auxHasFullEntropy)
    (lib.mesonOption "drng_reseed_threshold_bits" (toString drngReseedThresholdBits))
    (lib.mesonOption "drng_max_reseed_bits" (toString drngMaxReseedBits))
  ];

  doCheck = true;

  postFixup = lib.optionals fips140 ''
    $out/bin/esdm-tool --fips-checkfile $out/bin/.esdm-server.hmac \
                       --fips-targetfile $out/bin/esdm-server
  '';

  __structuredAttrs = true;
  mesonBuildType = "release";

  meta = {
    description = "Entropy Source and DRNG Manager in user space";
    homepage = "https://www.chronox.de/esdm.html";

    license = with lib.licenses; [
      gpl2Only
      bsd3
    ];

    maintainers = with lib.maintainers; [
      thillux
    ];

    platforms = lib.platforms.linux;
  };
})
