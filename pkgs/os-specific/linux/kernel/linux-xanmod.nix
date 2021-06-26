{ lib, stdenv, buildLinux, fetchFromGitHub, ... } @ args:

let
  version = "5.12.12";
  suffix = "xanmod1-cacule";
in
buildLinux (args // rec {
  inherit version;
  modDirVersion = "${version}-${suffix}";

  src = fetchFromGitHub {
    owner = "xanmod";
    repo = "linux";
    rev = modDirVersion;
    sha256 = "sha256-99gVqdYhnBx3MDTCCHbxsljmvi+DixHp19vtNwCRM/M=";
  };

  structuredExtraConfig = with lib.kernel; {
    PREEMPT = lib.mkForce yes;
    PREEMPT_VOLUNTARY = lib.mkForce no;
    NO_HZ_FULL = yes;
    HZ_500 = yes;
  };

  extraMeta = {
    branch = "5.12-cacule";
    maintainers = with lib.maintainers; [ fortuneteller2k ];
    description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
    broken = stdenv.hostPlatform.isAarch64;
  };
} // (args.argsOverride or { }))
