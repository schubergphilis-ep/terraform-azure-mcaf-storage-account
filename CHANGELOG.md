# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.11.2](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.11.1...v0.11.2) (2026-06-18)


### 🐛 Fixes

* variable validation of provisioned_billing_model ([#2](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/issues/2)) ([c2fdaef](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/c2fdaef7c21b3109ed735c65c4469ebc31b90675))

## [0.11.1](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.11.0...v0.11.1) (2026-06-08)


### 🐛 Fixes

* null access_tier on FileStorage shares so Azure stops rejecting them ([#28](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/28)) ([eeea859](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/eeea8591e10edbf3d8ce2dc0828839c7cfe267f1))

## [0.11.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.10.0...v0.11.0) (2026-03-31)


### 🚀 Features

* add provisioned v2 file share support ([#26](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/26)) ([cd6e1ee](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/cd6e1eeff1218ba081d16b4eada9c3cf919cecc4))

## [0.10.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.9.0...v0.10.0) (2025-07-28)


### 🚀 Features

* add storage share ids to output ([#25](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/25)) ([83aa433](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/83aa4332d930cf4d50933df43b4c53fd4c74a3f0))

## [0.9.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.8.4...v0.9.0) (2025-06-12)


### 🚀 Features

* Add capability to specify azure files authentication ([#24](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/24)) ([efa6264](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/efa626464233dbe801d51a58e7496c0fb473d0a4))

## [0.8.4](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.8.3...v0.8.4) (2025-04-17)


### 🚀 Features

* enhancement: extra output ([#23](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/23)) ([49d102c](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/49d102cb78d4aa864f47875d34f885d82919e30d))

## [0.8.3](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.8.2...v0.8.3) (2025-02-26)


### 🐛 Fixes

* Storagebackup ([#21](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/21)) ([b847393](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/b84739386f1fc0f42ec4f2965d06075bdc599fd2))

## [0.8.2](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.8.1...v0.8.2) (2025-02-25)


### 🐛 Fixes

* bug: Add storage_account_container_names property ([#20](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/20)) ([7750529](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/77505298de5261ef08788fbe7afd5ede02888c28))

## [0.8.1](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.7.3...v0.8.1) (2025-02-25)


### 🚀 Features

* Enabling Local user creation (SFTP Enabled : true) ([#17](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/17)) ([43c1258](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/43c125870b1fda61141a140160017196ef1de8a6))
* Add option to backup blob storage ([#16](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/16)) ([6dffaf3](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/6dffaf37ae9e966e481157784c080ed07ade035d))

### 🐛 Fixes

* bug: Blob storage backup ([#18](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/18)) ([97b3eba](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/97b3ebafecc8a461fd513cdd104e88e692eb2d21))

## [0.7.3](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.7.2...v0.7.3) (2025-02-24)

## [0.7.2](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.7.0...v0.7.2) (2025-02-20)


### 🚀 Features

* output-access-keys ([#15](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/15)) ([25fbb71](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/25fbb716185400633b9637b35cb6ea30a33f1622))
* enhancement: retention policy shares ([#13](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/13)) ([99477a0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/99477a0d34d1ff2dac6bcfc01dc2cb707a8d97c8))

## [0.7.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.6.0...v0.7.0) (2025-02-07)


### 🚀 Features

* enhancement: Share security options ([#12](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/12)) ([0116102](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/01161022e681dceca84d1317e0ddfb14c9ff050e))

## [0.6.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.5.1...v0.6.0) (2025-02-06)


### 🚀 Features

* change types from list to set ([#11](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/11)) ([efe5adf](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/efe5adf12db1469efd09e41e11a91184b7fbc7bb))
* enhancement: adding file share creation ([#10](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/10)) ([502300e](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/502300e0aa3fa3ea15d578b3a80a1667a66dc8d5))

## [0.5.1](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.5.0...v0.5.1) (2025-02-06)


### 🐛 Fixes

* bug: typo in PrivateLink ([#9](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/9)) ([3b9c822](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/3b9c8224144fe1baaf9bb2d02b488843f2e7f8da))

## [0.5.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.4.0...v0.5.0) (2025-02-06)


### 🚀 Features

* add basic storage management policy ([#8](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/8)) ([1fc70bb](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/1fc70bb3801c5bd3902af747e164aef85eedd35b))

## [0.4.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.3.0...v0.4.0) (2025-01-24)


### 🚀 Features

* add optional immutability policy ([#7](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/7)) ([3312f81](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/3312f81385b8f3433f567a52a3f9c302982375a9))

## [0.3.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.2.0...v0.3.0) (2025-01-23)


### 🚀 Features

* Allow user assigned identities ([#6](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/6)) ([7df9153](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/7df915394b853406bc1dad51783d4cf538f2128a))

## [0.2.0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/compare/v0.1.0...v0.2.0) (2025-01-23)


### 🚀 Features

* breaking: add option to enable cmk for queue and table ([#5](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/5)) ([53b9bc3](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/53b9bc37b0ca5581cbc235935cc455e6e29e0156))

## 0.1.0 (2024-12-06)


### 🚀 Features

* LRS to ZRS ([#4](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/4)) ([4ecc1f0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/4ecc1f02f57851510619cf2503abf19b13f1cd86))
* make the creation of containers optional ([#3](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/3)) ([bdf7d53](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/bdf7d5397a1a434fe6be1467f6cae1ec83254d99))
* misc: initial files ([#2](https://github.com/schubergphilis/terraform-azure-mcaf-storage-account/pull/2)) ([82a478e](https://github.com/schubergphilis-ep/terraform-azure-mcaf-storage-account/commit/82a478ee6e3f028cda46f274eb011cb3f4da35ac))
