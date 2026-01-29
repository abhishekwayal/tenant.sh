# 🕵️ crooksec – Tenant Domain Enumerator

A lightweight **Azure tenant OSINT & reconnaissance tool** designed for  
**red teamers, bug hunters, and security researchers**.

This script discovers **all domains associated with a Microsoft Entra ID
(Azure AD) tenant** using public OIDC metadata and tenant intelligence APIs.

---

## 🔥 Features

- ✅ Azure tenant ID discovery
- ✅ Enumerates all domains bound to a tenant
- ✅ Supports **single domain & bulk mode**
- ✅ Per-domain output files
- ✅ Silent mode (pipeline friendly)
- ✅ OPSEC-friendly delays

---

## 🧠 Use Cases

- Red Team pre-engagement reconnaissance
- Attack surface mapping
- Azure / Entra ID exposure analysis
- Bug bounty recon
- Cloud OSINT & threat intel enrichment

---

## 📦 Requirements

- `bash`
- `curl`
- `jq`

Install jq (if missing):

```bash
sudo apt install jq -y
