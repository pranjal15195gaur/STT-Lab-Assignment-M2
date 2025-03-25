import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
df = pd.read_csv("bandit_analysis.csv")  # Replace with your actual file name

# Convert timestamps if available (assuming a 'Timestamp' column exists)
# If your dataset has commit timestamps, ensure they're in datetime format
# df['Timestamp'] = pd.to_datetime(df['Timestamp'])

# Filter for high-severity vulnerabilities
high_severity_commits = df[df["High Severity"] > 0]

# Plot the number of high-severity vulnerabilities over time
plt.figure(figsize=(12, 6))
plt.hist(high_severity_commits["Commit"], bins=50, color='red', alpha=0.7)
plt.xlabel("Commits")
plt.ylabel("High Severity Count")
plt.title("High Severity Vulnerabilities Across Commits")
plt.xticks(rotation=90)
plt.show()

# Save the filtered high-severity data
high_severity_commits.to_csv("high_severity_commits.csv", index=False)

# Print summary statistics
print("Total high-severity vulnerabilities:", high_severity_commits.shape[0])
