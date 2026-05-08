markdown
# 🚀 IDMC to PySpark Converter - Complete Setup Guide

**Version**: 1.0  
**Last Updated**: 2026-05-08  
**Repository**: Nivedha-2195/Hackathon2026

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Creating Windows Shortcut](#creating-windows-shortcut)
5. [Workflow Overview](#workflow-overview)
6. [GitHub Configuration](#github-configuration)
7. [Troubleshooting](#troubleshooting)
8. [Examples](#examples)

---

## ✅ Prerequisites

Before you start, ensure you have the following installed:

### 1. **Python 3.7 or Higher**

**Windows Installation:**
- Download from: https://www.python.org/downloads/
- **IMPORTANT**: During installation, check ✓ "Add Python to PATH"
- Verify: Open Command Prompt and run:
  ```cmd
  python --version
  ```

### 2. **Git for Windows**

**Installation:**
- Download from: https://git-scm.com/download/win
- Use default installation settings
- Verify: Open Command Prompt and run:
  ```cmd
  git --version
  ```

### 3. **GitHub Account**

- Create account at: https://github.com
- Have your repository URL ready (format: `https://github.com/username/repo`)

### 4. **GitHub Personal Access Token (PAT)**

**Why**: For secure authentication without storing passwords

**How to create:**
1. Go to: https://github.com/settings/tokens/new
2. Give it a name (e.g., "IDMC Converter")
3. Select scopes:
   - ✓ `repo` (Full control of private repositories)
   - ✓ `workflow` (Update GitHub Action and deployment workflow YAML)
4. Click "Generate token"
5. **COPY AND SAVE IT** - You won't see it again!

---

## 📥 Installation

### Step 1: Clone the Repository

```bash
cd C:\Users\YourUsername\Documents
git clone https://github.com/Nivedha-2195/Hackathon2026
cd Hackathon2026
```

### Step 2: Verify Installation

Check that all files are present:

```
Hackathon2026/
├── idmc_converter.bat          ← Windows Batch Script
├── idmc_converter.py           ← Python Converter
├── SETUP_GUIDE.md              ← This file
├── input/                      ← Place input files here
├── output/                     ← Generated files here
├── temp/                       ← Temporary files
└── github_repo/                ← Local git clone
```

### Step 3: Create Required Directories

The batch script will create these automatically, but you can do it manually:

```cmd
mkdir input
mkdir output
mkdir temp
```

---

## 🎯 Quick Start

### **Option 1: Run Batch Script Directly**

```bash
cd C:\path\to\Hackathon2026
idmc_converter.bat
```

### **Option 2: Create and Use Windows Shortcut** (Recommended)

See [Creating Windows Shortcut](#creating-windows-shortcut) section below.

---

## 🔗 Creating Windows Shortcut

### **Method 1: Desktop Shortcut (Easy)**

1. **Right-click on Desktop** → **New** → **Shortcut**

2. **Enter Target Location:**
   ```
   cmd.exe /k "cd /d C:\Users\YOUR_USERNAME\Documents\Hackathon2026 && call idmc_converter.bat"
   ```
   
   ⚠️ Replace `YOUR_USERNAME` with your actual Windows username

3. **Name the Shortcut:**
   ```
   IDMC to PySpark Converter
   ```

4. **Click Finish** ✓

5. **Optional: Change Icon**
   - Right-click shortcut → Properties
   - Click "Change Icon..."
   - Select any icon you like

### **Method 2: Start Menu Shortcut**

1. Press `Win + R`
2. Type: `shell:startup`
3. Right-click → **New** → **Shortcut**
4. Enter target (same as above)
5. Name: `IDMC to PySpark Converter`
6. Click Finish

### **Method 3: Using Batch File (Advanced)**

Create a file named `create_shortcut.vbs` in the main directory:

```vbs
Set oWS = WScript.CreateObject("WScript.Shell")
strDesktop = oWS.SpecialFolders("Desktop")

Set oLink = oWS.CreateShortcut(strDesktop & "\IDMC to PySpark Converter.lnk")
oLink.TargetPath = "cmd.exe"
oLink.Arguments = "/k """ & CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".") & "\idmc_converter.bat"""
oLink.WorkingDirectory = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
oLink.Save
```

Double-click this file to create the shortcut automatically.

---

## 📊 Workflow Overview

```
START
  ↓
[Double-Click Shortcut]
  ↓
[idmc_converter.bat starts]
  ├─ Check Python installation
  ├─ Check Git installation
  ↓
[STEP 1: Input File Selection]
  ├─ Browse input/ folder
  ├─ Select XML/ZIP/JSON file
  ↓
[STEP 2: File Validation]
  ├─ Check file format
  ├─ Extract ZIP if needed
  ↓
[STEP 3: Parse IDMC Mapping]
  ├─ Run idmc_converter.py
  ├─ Extract source/target fields
  ├─ Identify transformations
  ├─ Parse lookup procedures
  ↓
[STEP 4: Generate PySpark Code]
  ├─ Create complete PySpark script
  ├─ Save to output/ folder
  ├─ Display summary
  ↓
[STEP 5: GitHub Configuration]
  ├─ Enter Repository URL
  ├─ Enter GitHub username
  ├─ Enter GitHub PAT
  ↓
[STEP 6: Git Clone/Update]
  ├─ Clone or pull latest from GitHub
  ↓
[STEP 7: Copy Output Files]
  ├─ Move PySpark files to github_repo/
  ↓
[STEP 8: Commit & Push]
  ├─ Add files to git
  ├─ Create commit message
  ├─ Push to GitHub
  ↓
[END - Success!]
  └─ Files available in repository
```

---

## 🔐 GitHub Configuration

### **First Time Setup**

The batch script will prompt you for:

1. **GitHub Repository URL**
   - Format: `https://github.com/username/repo`
   - Example: `https://github.com/Nivedha-2195/Hackathon2026`

2. **GitHub Username**
   - Your GitHub login username

3. **GitHub Personal Access Token**
   - The PAT you created (see prerequisites)

### **Storing Credentials (Optional)**

To avoid entering credentials every time, configure Git:

```cmd
# One-time setup
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
git config --global credential.helper wincred
```

Then Git Credential Manager will store your credentials securely.

---

## 📁 File Structure

After running the converter, you'll have:

```
Hackathon2026/
│
├── idmc_converter.bat              Main orchestration script
├── idmc_converter.py               Python conversion engine
├── SETUP_GUIDE.md                  This documentation
│
├── input/                          Place your IDMC files here
│   └── mt_m_customer.xml           (Sample input)
│
├── output/                         Generated PySpark code
│   └── mt_m_customer_pyspark.py    (Sample output)
│
├── temp/                           Temporary files (auto-cleanup)
│
├── github_repo/                    Local git clone
│   └── (contains your GitHub repo files)
│
└── idmc_converter.log              Execution log file
```

---

## 🐛 Troubleshooting

### **Problem: "Python is not installed or not in PATH"**

**Solution:**
1. Download Python from https://www.python.org/downloads/
2. During installation, **CHECK** the box: "Add Python to PATH"
3. Restart your computer
4. Try again

**Verify:**
```cmd
python --version
```

---

### **Problem: "Git is not installed or not in PATH"**

**Solution:**
1. Download Git from https://git-scm.com/download/win
2. Install with default settings
3. Restart Command Prompt
4. Try again

**Verify:**
```cmd
git --version
```

---

### **Problem: "File not found" during input selection**

**Solution:**
1. Place your IDMC file in the `input/` folder
2. Use exact filename with extension
3. Supported formats: `.xml`, `.zip`, `.json`

---

### **Problem: "Authentication failed" during GitHub push**

**Solution:**
1. Verify your GitHub PAT is correct
2. Ensure PAT has `repo` and `workflow` scopes
3. Try using Git Credential Manager: https://github.com/git-ecosystem/git-credential-manager

```cmd
git config --global credential.helper manager-core
```

---

### **Problem: Script runs but no output generated**

**Check:**
1. Look at `idmc_converter.log` for errors
2. Verify input file format (must be valid XML/JSON)
3. Check that input file has required IDMC elements
4. Ensure `output/` directory exists and is writable

---

### **Problem: Cannot connect to GitHub repository**

**Check:**
1. Repository URL is correct
2. Repository is public or you have access
3. Internet connection is working
4. No firewall blocking Git

**Manual Fix:**
```cmd
cd github_repo
git remote -v
git remote set-url origin https://github.com/username/repo
git pull
```

---

## 📝 Examples

### **Example 1: Simple IDMC Conversion**

**Input:** `customers_mapping.xml`

**Steps:**
1. Double-click IDMC to PySpark Converter shortcut
2. Enter: `customers_mapping.xml`
3. Enter: `https://github.com/Nivedha-2195/Hackathon2026`
4. Enter: your username
5. Enter: your GitHub PAT
6. Wait for completion ✓

**Output:** `customers_mapping_pyspark.py` in GitHub repo

---

### **Example 2: Batch Processing Multiple Files**

**Create a batch file:** `batch_convert.bat`

```batch
@echo off
cd /d C:\path\to\Hackathon2026

for %%F in (input\*.xml) do (
    echo Converting %%F...
    python idmc_converter.py "%%F" output
)

echo All files converted!
pause
```

---

### **Example 3: Automated Scheduling**

Use Windows Task Scheduler:

1. Press `Win + R` → Type `taskschd.msc`
2. Click "Create Task"
3. Set to run `idmc_converter.bat` on schedule
4. Configure trigger (daily, weekly, etc.)

---

## 📞 Support

If you encounter issues:

1. Check the log file: `idmc_converter.log`
2. Review this troubleshooting guide
3. Verify all prerequisites are installed
4. Check GitHub repository structure
5. Ensure file permissions are correct

---

## 🎓 Additional Resources

- **Python Documentation**: https://docs.python.org/3/
- **PySpark Documentation**: https://spark.apache.org/docs/latest/api/python/
- **Git Documentation**: https://git-scm.com/doc
- **GitHub Help**: https://docs.github.com/
- **Databricks PySpark Guide**: https://docs.databricks.com/

---

## ✨ Features

✅ Automated IDMC to PySpark conversion
✅ XML/ZIP/JSON file support
✅ Comprehensive error handling
✅ GitHub integration (auto-commit & push)
✅ Detailed logging
✅ Windows shortcut support
✅ No manual configuration needed
✅ Production-ready PySpark code generation

---

## 📄 License

This project is part of the Hackathon2026 initiative.

---

## 👥 Contributors

- Developed by: GitHub Copilot
- Repository: https://github.com/Nivedha-2195/Hackathon2026

---

**Last Updated**: 2026-05-08  
**Status**: ✅ Production Ready
