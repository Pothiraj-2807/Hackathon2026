# IDMC to PySpark Converter 🚀

A complete Windows automation solution to convert Informatica Data Management Cloud (IDMC) mapping definitions into production-ready PySpark code for Databricks execution.

---

## ⚡ Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Nivedha-2195/Hackathon2026
cd Hackathon2026

# 2. Create Windows Shortcut (see SETUP_GUIDE.md)
# Right-click Desktop → New → Shortcut
# Target: cmd.exe /k "cd /d C:\path\to\Hackathon2026 && call idmc_converter.bat"

# 3. Double-click the shortcut and follow prompts
```

---

## 📋 Features

✅ **Automated Conversion**
- Convert IDMC XML/ZIP/JSON to PySpark code automatically
- No manual configuration required
- Intelligent file detection and parsing

✅ **GitHub Integration**
- Auto-commit and push generated files
- Secure authentication with PAT
- Timestamped commit messages

✅ **Production Ready**
- Complete PySpark code with all transformations
- Comprehensive error handling
- Detailed inline documentation
- Data validation and logging

✅ **Windows Native**
- Simple batch script execution
- Desktop shortcut for easy access
- Detailed logging for troubleshooting
- Task Scheduler compatible

✅ **Comprehensive**
- Source field pass-through
- Lookup table joins
- Expression transformations
- Update strategy handling
- All derived fields included

---

## 📦 What's Included

| File | Purpose |
|------|---------|
| `idmc_converter.bat` | Main Windows batch orchestrator (12 KB) |
| `idmc_converter.py` | Python IDMC parsing & PySpark generation (10 KB) |
| `SETUP_GUIDE.md` | Complete setup and troubleshooting guide |
| `README.md` | This file |
| `input/` | Place your IDMC XML/ZIP/JSON files here |
| `output/` | Generated PySpark code saved here |
| `temp/` | Temporary working directory |

---

## 🎯 Workflow

```
IDMC XML/ZIP File
        ↓
Parse Mapping Structure
        ↓
Extract Fields & Transformations
        ↓
Generate PySpark Code
        ↓
Save to Output Directory
        ↓
Push to GitHub Repository
        ↓
✅ Ready for Databricks!
```

---

## 📥 Installation

### Prerequisites

- **Python 3.7+** - https://www.python.org/downloads/
  - Must add to PATH during installation
- **Git for Windows** - https://git-scm.com/download/win
- **GitHub Account** - https://github.com
- **GitHub Personal Access Token** - https://github.com/settings/tokens

### Step-by-Step Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/Nivedha-2195/Hackathon2026
   cd Hackathon2026
   ```

2. **Verify Prerequisites**
   ```cmd
   python --version
   git --version
   ```

3. **Create Windows Shortcut**
   - Right-click Desktop → New → Shortcut
   - Target: `cmd.exe /k "cd /d C:\Users\YOUR_USERNAME\Documents\Hackathon2026 && call idmc_converter.bat"`
   - Name: "IDMC to PySpark Converter"
   - Click Finish

4. **Place IDMC File**
   - Copy your IDMC XML/ZIP file to the `input/` folder

5. **Run Conversion**
   - Double-click the shortcut
   - Follow on-screen prompts
   - Provide GitHub credentials when asked

---

## 💻 Usage

### Basic Usage

```bash
# Run directly
idmc_converter.bat

# Or run Python converter directly
python idmc_converter.py input_file.xml output_directory/
```

### With GitHub Integration

1. Run the batch script
2. Select input file when prompted
3. Enter GitHub repository URL
4. Enter GitHub username and PAT
5. Files automatically committed and pushed

### Batch Processing Multiple Files

Create `batch_convert.bat`:
```batch
@echo off
cd /d C:\path\to\Hackathon2026

for %%F in (input\*.xml) do (
    echo Converting %%F...
    python idmc_converter.py "%%F" output
)
```

---

## 📊 Output Example

### Input: IDMC Mapping
```xml
<MAPPING NAME="Mapping0">
    <SOURCEFIELD NAME="Customer_Id"/>
    <SOURCEFIELD NAME="First_Name"/>
    <SOURCEFIELD NAME="Last_Name"/>
    <TARGETFIELD NAME="FULL_NAME"/>
    <TRANSFORMATION TYPE="Expression">
        <EXPRESSION>UPPER(First_Name)||UPPER(Last_Name)</EXPRESSION>
    </TRANSFORMATION>
</MAPPING>
```

### Output: PySpark Code
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, upper, concat

spark = SparkSession.builder.appName("idmc_mapping").getOrCreate()

df_source = spark.read.csv("source_path", header=True)

df_transformed = df_source.select(
    col("Customer_Id"),
    col("First_Name"),
    col("Last_Name"),
    concat(upper(col("First_Name")), upper(col("Last_Name"))).alias("FULL_NAME")
)

df_transformed.write.csv("output_path", header=True, mode="overwrite")
```

---

## 🔧 Configuration

### GitHub Setup

**Create Personal Access Token:**

1. Go to https://github.com/settings/tokens/new
2. Name: "IDMC Converter"
3. Select Scopes:
   - ✓ `repo` - Full repository access
   - ✓ `workflow` - GitHub Actions
4. Generate and copy token
5. Provide during script execution

### Git Credentials

**Store credentials securely (optional):**

```cmd
git config --global credential.helper wincred
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

---

## 📝 Generated PySpark Features

The generated PySpark code includes:

✅ All source fields (pass-through)
✅ Lookup table joins
✅ Expression transformations
✅ Derived field calculations
✅ Data type handling
✅ Null value management
✅ Error handling
✅ Comprehensive comments
✅ Production-ready structure

---

## 🐛 Troubleshooting

### Python Not Found
```bash
# Verify installation
python --version

# Add to PATH if needed
# Control Panel → System → Environment Variables
# Add Python installation directory to PATH
```

### Git Not Found
```bash
# Verify installation
git --version

# Reinstall from https://git-scm.com/download/win
```

### GitHub Authentication Failed
```bash
# Check PAT validity and scopes
# Verify internet connection
# Try: git config --global credential.helper manager-core
```

### No Output Generated
- Check `idmc_converter.log` for errors
- Verify input file format (valid XML/JSON)
- Ensure `output/` directory is writable
- Check for IDMC elements in XML

For detailed troubleshooting, see **SETUP_GUIDE.md**.

---

## 📊 Repository Structure

```
Hackathon2026/
├── idmc_converter.bat          Main orchestration script
├── idmc_converter.py           Python conversion engine
├── SETUP_GUIDE.md              Complete documentation
├── README.md                   This file
│
├── input/                      Place IDMC files here
│   └── mt_m_customer.xml       Sample input
│
├── output/                     Generated code here
│   └── mt_m_customer_pyspark.py Sample output
│
├── temp/                       Temporary files
├── github_repo/                Local git clone
└── idmc_converter.log          Execution log
```

---

## 🎓 Examples

### Example 1: Customer Mapping
```bash
# Input: customers_mapping.xml
# Contains: Source (100 fields) → Target (150 fields)
# Output: Full PySpark transformation code
idmc_converter.bat
# Select: customers_mapping.xml
# Result: customers_mapping_pyspark.py
```

### Example 2: Batch Processing
```bash
# Convert all XML files in input/ folder
# Automatically
for %f in (input\*.xml) do python idmc_converter.py "%f" output
```

### Example 3: Schedule Daily Runs
```bash
# Use Windows Task Scheduler
# Run idmc_converter.bat daily at 9 AM
# Automatically push changes to GitHub
```

---

## 🚀 Deployment to Databricks

1. **Get generated PySpark file** from GitHub repository
2. **Open Databricks workspace**
3. **Create new notebook** and paste code
4. **Update file paths** for your data sources
5. **Run notebook** in your Databricks cluster
6. **Monitor execution** and check output

---

## 📞 Support

### Documentation
- **SETUP_GUIDE.md** - Complete setup and troubleshooting
- **Code comments** - Inline documentation in generated PySpark
- **Log file** - `idmc_converter.log` for debugging

### Resources
- PySpark Docs: https://spark.apache.org/docs/latest/api/python/
- Databricks Docs: https://docs.databricks.com/
- IDMC Docs: https://docs.informatica.com/
- Git Help: https://git-scm.com/doc

---

## 🔐 Security

✅ **Credentials Handling**
- GitHub PAT stored in Git Credential Manager
- No passwords stored in code or logs
- All operations logged for audit

✅ **File Permissions**
- Only read source files
- Write output to designated directory
- Secure git operations

---

## 📄 License

This project is part of **Hackathon2026** initiative.

---

## 👥 Contributors

- **Developer**: GitHub Copilot
- **Repository**: https://github.com/Nivedha-2195/Hackathon2026

---

## ✨ Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-08 | Initial release with Windows automation |

---

## ✅ Production Ready

This solution is **production-ready** and includes:
- ✓ Error handling
- ✓ Comprehensive logging
- ✓ GitHub integration
- ✓ Complete documentation
- ✓ Sample files
- ✓ Troubleshooting guide

---

**Status**: ✅ ACTIVE  
**Last Updated**: 2026-05-08  
**Support**: See SETUP_GUIDE.md for detailed help
