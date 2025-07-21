# employee_data_cleaning.py

import pandas as pd

# Sample employee data
data = {
    'emp_id': [101, 102, 103, 104, 105, 101],
    'name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Alice'],
    'department': ['HR', 'Finance', None, 'IT', 'Finance', 'HR'],
    'salary': [70000, 80000, None, 65000, 82000, 70000]
}

# Create DataFrame
df = pd.DataFrame(data)
print("Original Data:")
print(df)

# Remove duplicates
df = df.drop_duplicates()
print("\nAfter Removing Duplicates:")
print(df)

# Fill missing salary with mean
df['salary'] = df['salary'].fillna(df['salary'].mean())

# Fill missing department with 'Unknown'
df['department'] = df['department'].fillna('Unknown')

# Rename column
df.rename(columns={'emp_id': 'employee_id'}, inplace=True)

print("\nCleaned Data:")
print(df)

# Save to CSV (optional)
df.to_csv('cleaned_employee_data.csv', index=False)
