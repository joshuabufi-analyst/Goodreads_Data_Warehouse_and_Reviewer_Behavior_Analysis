import pandas as pd
import os

# Read the CSV file
csv_path = r"C:\Users\Asus\Downloads\Portfolios\Goodreads+Book+Reviews\goodreads_reviews.csv"
df = pd.read_csv(csv_path)

# Replace all commas with "/" in string type columns only
string_columns = df.select_dtypes(include=['object']).columns
for col in string_columns:
    df[col] = df[col].str.replace(',', '/', regex=False)

# Define the output folder
output_folder = os.path.join(os.getcwd(), 'cleaned csv')

# Create the folder if it doesn't exist
os.makedirs(output_folder, exist_ok=True)

# Save the cleaned data
output_path = os.path.join(output_folder, 'goodreads_reviews_cleaned.csv')
df.to_csv(output_path, index=False)

print(f"✓ Cleaned file saved to: {output_path}")
print(f"\nTotal rows processed: {len(df)}")
print(f"\nFirst 5 rows:")
print(df.head(5))

