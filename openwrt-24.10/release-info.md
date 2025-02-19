## Vanilla OpenWrt 24.10

### General Info
- Based on official Openwrt 24.10.0

### Notes
- Includes patches for PHY PCIe init issues
- R4S is over-clocked to 2.0GHz on a72 cores and 1.6GHz on a53 cores.
- CycloneDX SBOM and full manifest is included in each release
- All kmods included in each release image

### Configuration
- OpenWRT 24.10 Vanilla / Kernel 6.6
- 1024MB rootfs partition size

### Applications
- Same application set as official OpenWrt build

### Changelog
- [2025-02-06] Initial OpenWrt 24.10.0
- [2025-02-17] Add patches for PHY PCIe init issues
- [2025-02-18] Trim build back to plain vanilla Openwrt with only PHY PCIe init issue patches, OC patch, and patch for LED system status
