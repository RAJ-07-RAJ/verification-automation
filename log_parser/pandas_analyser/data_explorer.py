import pandas as pd
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths

csv_file = paths.REPORTS / "extracted_failures.csv"

df = pd.read_csv(csv_file)

# basic exploration — run this first, understand what you have
print("Shape:", df.shape)           # rows x columns
print("\nColumns:", df.columns.tolist())
print("\nFirst 5 rows:")
print(df.head())
print("\nData types:")
print(df.dtypes)
print("\nNull counts:")
print(df.isnull().sum())