# ==========================================
# IDMC Mapping to PySpark Conversion
# Mapping Name: Mapping0 (mt_m_customer)
# Source: customers_100.csv (Flat File)
# Target: customers_100.csv (Flat File)
# ==========================================

from pyspark.sql import SparkSession, Window
from pyspark.sql.functions import (
    col, upper, concat, lit, current_timestamp, 
    coalesce, when, to_timestamp, trim
)
from pyspark.sql.types import StructType, StructField, StringType, TimestampType
from datetime import datetime

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("mt_m_customer_mapping") \
    .getOrCreate()

# ==========================================
# Step 1: Read Source File - customers_100.csv
# ==========================================
# Source Configuration:
# - File Type: Flat File (CSV)
# - Delimiter: ,
# - Skip Rows: 1 (header)
# - Codepage: UTF-8
# - Quote Character: DOUBLE

source_file_path = "C:/Users/hackathon12/Documents/IDMC/customers-100.csv"

df_source = spark.read \
    .option("header", "true") \
    .option("delimiter", ",") \
    .option("encoding", "UTF-8") \
    .option("quote", "\"") \
    .option("escapeQuotes", "true") \
    .option("inferSchema", "true") \
    .csv(source_file_path)

# Display source schema and data
print("=== SOURCE DATA ===")
print(f"Source Record Count: {df_source.count()}")
df_source.printSchema()
df_source.show(5)

# ==========================================
# Step 2: Load Lookup Table - COMPANY_CODE.csv
# ==========================================
# Lookup Procedure: LKP_COMPANY_CODE
# Lookup Condition: Company = I_COMPANY
# Lookup Fields: Company (Input), COMPANY_CODE (Return)
# Source Type: Flat File
# File: COMPANY_CODE.csv

lookup_file_path = "C:/Users/hackathon12/Documents/IDMC/COMPANY_CODE.csv"

df_company_lookup = spark.read \
    .option("header", "true") \
    .option("delimiter", ",") \
    .option("encoding", "UTF-8") \
    .option("quote", "\"") \
    .option("escapeQuotes", "true") \
    .option("inferSchema", "true") \
    .csv(lookup_file_path)

# Cache lookup table for better performance
df_company_lookup.cache()

print("\n=== LOOKUP TABLE (COMPANY_CODE) ===")
print(f"Lookup Record Count: {df_company_lookup.count()}")
df_company_lookup.printSchema()
df_company_lookup.show(5)

# ==========================================
# Step 3: Apply Lookup - LKP_COMPANY_CODE
# ==========================================
# Join source with lookup table on Company field
# Left join to preserve all source records

df_with_lookup = df_source.join(
    df_company_lookup,
    df_source["Company"] == df_company_lookup["Company"],
    "left"
).select(
    df_source["*"],
    coalesce(df_company_lookup["COMPANY_CODE"], lit(None)).alias("CMPNY_CD_LOOKUP")
)

print("\n=== AFTER LOOKUP JOIN ===")
df_with_lookup.show(5)

# ==========================================
# Step 4: Apply Expression Transformations
# ==========================================
# Expression Transformation:
# 1. FULL_NAME = UPPER(First_Name) || UPPER(Last_Name)
# 2. CRTN_ID = 'DEVELOPER'
# 3. CRTN_DT_TM = SYSDATE (current timestamp)
# 4. CMPNY_CD = Lookup result from LKP_COMPANY_CODE

df_transformed = df_with_lookup.select(
    # Pass-through fields (Source Qualifier)
    col("Index"),
    col("Customer_Id"),
    col("First_Name"),
    col("Last_Name"),
    col("Company"),
    col("City"),
    col("Country"),
    col("Phone_1"),
    col("Phone_2"),
    col("Email"),
    col("Subscription_Date"),
    col("Website"),
    
    # Derived Field 1: FULL_NAME
    # Expression: UPPER(First_Name) || UPPER(Last_Name)
    # Concatenate uppercase first name and last name
    concat(
        upper(col("First_Name")),
        upper(col("Last_Name"))
    ).alias("FULL_NAME"),
    
    # Derived Field 2: CRTN_ID
    # Expression: 'DEVELOPER'
    # Constant literal value
    lit("DEVELOPER").alias("CRTN_ID"),
    
    # Derived Field 3: CRTN_DT_TM
    # Expression: SYSDATE
    # Current timestamp when record is created
    current_timestamp().cast(StringType()).alias("CRTN_DT_TM"),
    
    # Derived Field 4: CMPNY_CD
    # Expression: :LKP.LKP_COMPANY_CODE(Company)
    # Lookup result - use coalesce to handle null values
    coalesce(col("CMPNY_CD_LOOKUP"), lit("UNKNOWN")).alias("CMPNY_CD")
)

print("\n=== AFTER EXPRESSION TRANSFORMATION ===")
print(f"Transformed Record Count: {df_transformed.count()}")
df_transformed.printSchema()
df_transformed.show(5)

# ==========================================
# Step 5: Apply Update Strategy
# ==========================================
# Update Strategy: DD_INSERT (Insert new records)
# All records will be inserted (no update logic)

df_final = df_transformed

print("\n=== FINAL TRANSFORMED DATA (READY FOR INSERT) ===")
print(f"Final Record Count: {df_final.count()}")
df_final.printSchema()
df_final.show(10)

# ==========================================
# Step 6: Write Output to Target File
# ==========================================
# Target Configuration:
# - File Type: Flat File (CSV)
# - Delimiter: ,
# - Header: YES
# - Codepage: UTF-8
# - Quote Character: DOUBLE

target_file_path = "C:/Users/hackathon12/Downloads/tgt/customers-100.csv"

# Write to CSV with headers
df_final.coalesce(1).write \
    .option("header", "true") \
    .option("delimiter", ",") \
    .option("encoding", "UTF-8") \
    .option("quote", "\"") \
    .option("escapeQuotes", "true") \
    .mode("overwrite") \
    .csv(target_file_path)

print(f"\n=== OUTPUT WRITTEN ===")
print(f"Target file written to: {target_file_path}")

# ==========================================
# Step 7: Display Field Mapping Summary
# ==========================================
print("\n" + "="*80)
print("FIELD MAPPING SUMMARY")
print("="*80)

mapping_summary = [
    ("Index", "Index", "Pass-through", "Index"),
    ("Customer_Id", "Customer_Id", "Pass-through", "Customer_Id"),
    ("First_Name", "First_Name", "Pass-through", "First_Name"),
    ("Last_Name", "Last_Name", "Pass-through", "Last_Name"),
    ("Company", "Company", "Pass-through", "Company"),
    ("City", "City", "Pass-through", "City"),
    ("Country", "Country", "Pass-through", "Country"),
    ("Phone_1", "Phone_1", "Pass-through", "Phone_1"),
    ("Phone_2", "Phone_2", "Pass-through", "Phone_2"),
    ("Email", "Email", "Pass-through", "Email"),
    ("Subscription_Date", "Subscription_Date", "Pass-through", "Subscription_Date"),
    ("Website", "Website", "Pass-through", "Website"),
    ("First_Name + Last_Name", "FULL_NAME", "Expression", "UPPER(First_Name) || UPPER(Last_Name)"),
    ("Literal", "CRTN_ID", "Expression", "'DEVELOPER'"),
    ("Current Timestamp", "CRTN_DT_TM", "Expression", "SYSDATE / current_timestamp()"),
    ("LKP_COMPANY_CODE", "CMPNY_CD", "Lookup Join", ":LKP.LKP_COMPANY_CODE(Company)"),
]

print("\nSOURCE → TRANSFORMATION → TARGET\n")
for source, target, trans_type, logic in mapping_summary:
    print(f"{source:<30} → {trans_type:<20} → {target:<20}")
    print(f"  Logic: {logic}")
    print()

print("="*80)
print("TRANSFORMATION DETAILS")
print("="*80)
print("""
✓ Source Qualifier: 
  - Read all 12 fields from customers_100.csv
  - Skip header row
  
✓ Lookup Procedure (LKP_COMPANY_CODE):
  - Loads COMPANY_CODE.csv lookup file
  - Joins on Company field
  - Returns COMPANY_CODE for each company
  
✓ Expression Transformation:
  - FULL_NAME: Concatenates UPPER(First_Name) + UPPER(Last_Name)
  - CRTN_ID: Constant value 'DEVELOPER'
  - CRTN_DT_TM: Current system timestamp
  - CMPNY_CD: Lookup result from LKP_COMPANY_CODE
  
✓ Update Strategy:
  - DD_INSERT: All records treated as new inserts
  
✓ Target Writer:
  - Writes to customers-100.csv
  - Includes all source fields + 4 derived fields
  - Total output: 16 fields
""")

# ==========================================
# Step 8: Data Quality Validation
# ==========================================
print("\n" + "="*80)
print("DATA QUALITY VALIDATION")
print("="*80)

# Count records
src_count = df_source.count()
tgt_count = df_final.count()

print(f"\nSource Records: {src_count}")
print(f"Target Records: {tgt_count}")
print(f"Match: {'✓ YES' if src_count == tgt_count else '✗ NO'}")

# Check for nulls in key fields
print("\n--- NULL Value Check ---")
null_check = df_final.select([
    (col(c).isNull().cast("integer")).alias(c) 
    for c in df_final.columns
]).groupBy().sum().collect()[0].asDict()

for col_name, null_count in null_check.items():
    if null_count > 0:
        print(f"⚠ {col_name}: {null_count} NULL values")
    else:
        print(f"✓ {col_name}: No NULL values")

# Sample output
print("\n--- Sample Output Records ---")
df_final.show(5, truncate=False)

# Stop Spark Session
spark.stop()
print("\n✓ Spark Session Closed - Mapping Complete!")
