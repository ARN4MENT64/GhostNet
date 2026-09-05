# GhostNet
GhostNet v1.0.0 is a serverless P2P chat by ARN4MENT built for isolated Wi-Fi/LAN networks without internet or central servers. Features smart UDP Broadcast for auto-discovery, global English UI, and full Russian text support. 

An autonomous, serverless P2P (Peer-to-Peer) chat designed to operate entirely in local isolated networks (Wi-Fi Hotspots / Ad-Hoc / LAN) without relying on global internet access or external servers.

Developed by **ARN4MENT** as part of the decentralized software ecosystem (alongside **CNetwork v1.0.0**).

## ⚡ Features
- **Pure P2P Architecture:** No central server, no databases, no user registration. Every node is equal.
- **Smart Discovery:** Uses UDP Broadcast to automatically scan the local airwaves and discover other peers without needing to know their IP addresses beforehand.
- **Zero Configuration:** Automatically detects and frees bound ports from previous stale sessions.
- **Universal Encoding:** Full UTF-8 support for seamless international messaging (including Cyrillic).
- **Standalone:** Can be compiled into a single `.exe` file with zero external dependencies.

## 🚀 How It Works
1. One device creates a local Wi-Fi Hotspot (or joins an existing LAN).
2. Another device connects to this network.
3. Both users launch `GhostNet.exe`.
4. Type any message to initiate the broadcast scan. The devices will automatically pair and switch to a direct P2P connection.

## 🛠️ How to Compile (Windows)
Open PowerShell as Administrator, install the compilation module, and run the build command:

## ⚠️ Windows Defender Note (False Positive)
Because `GhostNet.exe` is compiled from a PowerShell script using `ps2exe` and handles low-level network sockets, **Windows Defender may flag it as a threat** (e.g., *Trojan:Win32/Script*). This is a known **false positive** common for unsigned open-source security tools.

### How to verify and run safely:
1. **Verify the Source:** You can open the raw `GhostNet.ps1` file using Notepad or any text editor to verify that the code contains no malicious payloads or backdoors.
2. **Compile it Yourself:** Follow the instructions in the "How to Compile" section to generate your own executable from the verified source code.
3. **Add an Exclusion:** If you want to use the pre-compiled binary from the Releases tab:
   - Go to *Windows Security* -> *Virus & threat protection* -> *Manage settings*.
   - Scroll down to *Exclusions* -> *Add or remove exclusions*.
   - Add the folder containing `GhostNet.exe` or allow the file from the *Protection history*.

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
Invoke-PS2EXE -InputFile ".\wifi-chat.ps1" -OutputFile ".\GhostNet.exe" -Title "GhostNet" -Description "Autonomous P2P Chat" -Company "ARN4MENT" -Product "GhostNet" -Version "1.0.0"
```

## 📜 License
This project is open-source and free to distribute. Built for educational and defensive networking research.
