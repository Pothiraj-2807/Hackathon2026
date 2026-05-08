#!/usr/bin/env python3
# ==========================================
# IDMC to PySpark Converter - Python Module
# ==========================================
# Description: Converts IDMC XML/JSON mapping exports to executable PySpark code
# Author: Hackathon2026
# Date: 2026-05-08
# ==========================================

import xml.etree.ElementTree as ET
import json
import sys
import os
from datetime import datetime
from pathlib import Path

class IDMCToPySpark:
    """Converts IDMC mapping definitions to PySpark code"""
    
    def __init__(self, input_file, output_dir):
        self.input_file = input_file
        self.output_dir = output_dir
        self.mapping_data = {}
        self.source_fields = []
        self.target_fields = []
        self.transformations = {}
        self.lookups = {}
        
    def parse_xml(self):
        """Parse IDMC XML file"""
        try:
            tree = ET.parse(self.input_file)
            root = tree.getroot()
            
            # Extract source fields
            for source_field in root.findall(".//SOURCEFIELD"):
                field_name = source_field.get("NAME")
                field_type = source_field.get("DATATYPE")
                self.source_fields.append({
                    "name": field_name,
                    "type": field_type,
                    "business_name": source_field.get("BUSINESSNAME")
                })
            
            # Extract target fields
            for target_field in root.findall(".//TARGETFIELD"):
                field_name = target_field.get("NAME")
                field_type = target_field.get("DATATYPE")
                self.target_fields.append({
                    "name": field_name,
                    "type": field_type,
                    "business_name": target_field.get("BUSINESSNAME")
                })
            
            # Extract transformations
            for transformation in root.findall(".//TRANSFORMATION[@TYPE='Expression']"):
                trans_name = transformation.get("NAME")
                self.transformations[trans_name] = []
                
                for field in transformation.findall(".//TRANSFORMFIELD[@PORTTYPE='OUTPUT']"):
                    field_name = field.get("NAME")
                    expression = field.get("EXPRESSION")
                    self.transformations[trans_name].append({
                        "name": field_name,
                        "expression": expression
                    })
            
            # Extract lookups
            for lookup in root.findall(".//TRANSFORMATION[@TYPE='Lookup Procedure']"):
                lookup_name = lookup.get("NAME")
                lookup_condition = lookup.find(".//TABLEATTRIBUTE[@NAME='Lookup condition']")
                lookup_table = lookup.find(".//TABLEATTRIBUTE[@NAME='Lookup table name']")
                
                self.lookups[lookup_name] = {
                    "condition": lookup_condition.get("VALUE") if lookup_condition is not None else "",
                    "table": lookup_table.get("VALUE") if lookup_table is not None else ""
                }
            
            return True
            
        except Exception as e:
            print(f"Error parsing XML: {e}")
            return False
    
    def generate_pyspark_code(self):
        """Generate PySpark code from parsed IDMC data"""
        
        pyspark_code = '''# ==========================================
# IDMC Mapping to PySpark Conversion
# Generated: {timestamp}
# Input File: {input_file}
# ==========================================

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, upper, concat, lit, current_timestamp, 
    coalesce, when, to_timestamp, trim
)
from pyspark.sql.types import StructType, StructField, StringType, TimestampType
from datetime import datetime

# Initialize Spark Session
spark = SparkSession.builder \\
    .appName("idmc_mapping_conversion") \\
    .getOrCreate()

# ==========================================
# SOURCE FIELDS ({source_count})
# ==========================================
source_fields = {source_fields}

# ==========================================
# TARGET FIELDS ({target_count})
# ==========================================
target_fields = {target_fields}

# ==========================================
# Step 1: Read Source Data
# ==========================================
# TODO: Configure your source path and format
source_path = "your_source_path_here"

df_source = spark.read \\
    .option("header", "true") \\
    .option("inferSchema", "true") \\
    .csv(source_path)

print("Source Data:")
df_source.printSchema()
df_source.show(5)

# ==========================================
# Step 2: Load Lookup Tables (if any)
# ==========================================
{lookups_code}

# ==========================================
# Step 3: Apply Transformations
# ==========================================
{transformations_code}

# ==========================================
# Step 4: Write Output
# ==========================================
output_path = "your_output_path_here"

df_final.coalesce(1).write \\
    .option("header", "true") \\
    .mode("overwrite") \\
    .csv(output_path)

print(f"Output written to: {{output_path}}")

# Stop Spark Session
spark.stop()
'''.format(
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            input_file=os.path.basename(self.input_file),
            source_count=len(self.source_fields),
            source_fields=self._format_list(self.source_fields),
            target_count=len(self.target_fields),
            target_fields=self._format_list(self.target_fields),
            lookups_code=self._generate_lookup_code(),
            transformations_code=self._generate_transformation_code()
        )
        
        return pyspark_code
    
    def _format_list(self, items):
        """Format list for display"""
        if not items:
            return "[]"
        
        formatted = "[\n"
        for item in items:
            formatted += f"    {item},\n"
        formatted += "]"
        return formatted
    
    def _generate_lookup_code(self):
        """Generate lookup table code"""
        if not self.lookups:
            return "# No lookups defined"
        
        code = "# Load lookup tables\n"
        for lookup_name, lookup_info in self.lookups.items():
            code += f'''
# Lookup: {lookup_name}
# Condition: {lookup_info['condition']}
# Table: {lookup_info['table']}

lookup_path = "your_lookup_path_here"
df_{lookup_name} = spark.read \\
    .option("header", "true") \\
    .csv(lookup_path)

df_{lookup_name}.cache()
'''
        return code
    
    def _generate_transformation_code(self):
        """Generate transformation code"""
        if not self.transformations:
            return "# No transformations defined\ndf_transformed = df_source"
        
        code = "# Apply transformations\ndf_transformed = df_source.select(\n"
        
        # Add source fields
        for field in self.source_fields:
            code += f"    col(\"{field['name']}\"),\n"
        
        # Add derived fields
        for trans_name, fields in self.transformations.items():
            for field in fields:
                expression = field['expression']
                code += f"    # {trans_name}: {field['name']}\n"
                code += f"    # Expression: {expression}\n"
                code += f"    lit(None).alias(\"{field['name']}\"),\n"
        
        code += ")\n"
        return code
    
    def save_pyspark_code(self, filename="idmc_converted.py"):
        """Save generated PySpark code to file"""
        try:
            output_path = Path(self.output_dir) / filename
            
            pyspark_code = self.generate_pyspark_code()
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(pyspark_code)
            
            print(f"✓ PySpark code generated: {output_path}")
            return True
            
        except Exception as e:
            print(f"✗ Error saving PySpark code: {e}")
            return False
    
    def convert(self):
        """Main conversion method"""
        try:
            print(f"Processing: {self.input_file}")
            print(f"Output: {self.output_dir}")
            print()
            
            # Parse input file
            print("Parsing IDMC file...")
            if not self.parse_xml():
                return False
            
            print(f"  - Source fields found: {len(self.source_fields)}")
            print(f"  - Target fields found: {len(self.target_fields)}")
            print(f"  - Transformations found: {len(self.transformations)}")
            print(f"  - Lookups found: {len(self.lookups)}")
            print()
            
            # Create output directory if it doesn't exist
            Path(self.output_dir).mkdir(parents=True, exist_ok=True)
            
            # Generate and save PySpark code
            print("Generating PySpark code...")
            if self.save_pyspark_code():
                print()
                print("✓ Conversion completed successfully!")
                return True
            else:
                print("✗ Failed to save PySpark code")
                return False
                
        except Exception as e:
            print(f"✗ Conversion error: {e}")
            return False


def main():
    """Main entry point"""
    if len(sys.argv) < 3:
        print("Usage: python idmc_converter.py <input_file> <output_directory>")
        print()
        print("Supported input formats:")
        print("  - XML files (.xml) - IDMC mapping export")
        print("  - JSON files (.json) - IDMC configuration")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_dir = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"Error: Input file not found: {input_file}")
        sys.exit(1)
    
    converter = IDMCToPySpark(input_file, output_dir)
    
    if converter.convert():
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
